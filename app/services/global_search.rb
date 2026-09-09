class GlobalSearch
  GROUP_ORDER = %w[news partner application financial event mvp].freeze
  PREVIEW_LIMIT = 5

  def initialize(query:, type: nil)
    @query = query.to_s.strip
    @type = type.presence
  end

  def call
    return empty_result unless searchable_query.present?

    rows = connection.exec_query(search_sql)
    count_rows = connection.exec_query(count_sql)
    documents = rows.map { |row| result_from(row) }
    counts = count_rows.each_with_object({}) { |row, result| result[row["record_type"]] = row["count"].to_i }
    groups = GROUP_ORDER.each_with_object({}) do |type, result|
      matches = documents.select { |document| document[:record_type] == type }
      result[type] = {
        results: matches.first(PREVIEW_LIMIT),
        count: counts.fetch(type, 0),
        more: matches.length > PREVIEW_LIMIT
      } if matches.any?
    end

    {
      query: @query,
      total_count: counts.values.sum,
      exact_matches: documents.select { |document| document[:exact_match] },
      groups: groups
    }
  end

  private

  def empty_result
    { query: @query, total_count: 0, exact_matches: [], groups: {} }
  end

  def searchable_query
    @tokens ||= @query.scan(/[[:alnum:]_]+/)
  end

  def fts_query
    searchable_query.map { |token| %("#{token.gsub('"', '')}"*) }.join(" AND ")
  end

  def search_sql
    where_type = @type.present? ? "AND d.record_type = #{connection.quote(@type)}" : ""
    <<~SQL
      SELECT d.*,
             CASE WHEN lower(d.title) = lower(#{connection.quote(@query)}) THEN 0 ELSE 1 END AS exact_rank,
             bm25(search_documents_fts, 8.0, 4.0, 1.0, 0.2) AS relevance,
             snippet(search_documents_fts, 2, '<mark>', '</mark>', '…', 18) AS content_excerpt
      FROM search_documents_fts
      JOIN search_documents d ON d.id = search_documents_fts.rowid
      WHERE search_documents_fts MATCH #{connection.quote(fts_query)}
        #{where_type}
      ORDER BY exact_rank ASC, relevance ASC, occurred_at DESC, d.record_type ASC, d.record_id ASC
      LIMIT 100
    SQL
  end

  def count_sql
    where_type = @type.present? ? "AND d.record_type = #{connection.quote(@type)}" : ""
    <<~SQL
      SELECT d.record_type, COUNT(*) AS count
      FROM search_documents_fts
      JOIN search_documents d ON d.id = search_documents_fts.rowid
      WHERE search_documents_fts MATCH #{connection.quote(fts_query)}
        #{where_type}
      GROUP BY d.record_type
    SQL
  end

  def result_from(row)
    row = row.symbolize_keys
    excerpt = row[:content_excerpt].presence || row[:subtitle].presence || row[:title]
    {
      record_type: row[:record_type],
      type_label: SearchDocument::TYPES.fetch(row[:record_type], row[:record_type].humanize),
      title: row[:title],
      subtitle: row[:subtitle],
      excerpt: excerpt,
      local_path: row[:local_path],
      source_url: row[:url].presence,
      destination_label: row[:destination_label],
      occurred_at: row[:occurred_at],
      exact_match: row[:exact_rank].to_i.zero?
    }
  end

  def connection
    ActiveRecord::Base.connection
  end
end
