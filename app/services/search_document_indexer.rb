class SearchDocumentIndexer
  BATCH_SIZE = 500

  def self.rebuild!
    new.rebuild!
  end

  def rebuild!
    SearchDocument.delete_all
    write_collection(NewsItem.active) { |record| news_document(record) }
    write_collection(Company.active.partners) { |record| partner_document(record) }
    write_collection(ServicenowStoreApp.all) { |record| application_document(record) }
    write_collection(ServicenowInvestment.all) { |record| financial_document(record) }
    write_collection(KnowledgeSession.all) { |record| event_document(record) }
    write_mvp_documents

    connection.execute("INSERT INTO search_documents_fts(search_documents_fts) VALUES('rebuild')")
    connection.execute("INSERT INTO search_documents_fts(search_documents_fts) VALUES('optimize')")
    SearchDocument.count
  end

  private

  def write_collection(scope)
    scope.find_in_batches(batch_size: BATCH_SIZE) do |records|
      SearchDocument.insert_all(records.map { |record| yield(record) }, record_timestamps: false)
    end
  end

  def write_mvp_documents
    awards = MvpAward.includes(:participant).order(:participant_id).to_a
    awards.group_by(&:participant_id).each_value do |participant_awards|
      participant = participant_awards.first.participant
      SearchDocument.insert!(mvp_document(participant, participant_awards))
    end
  end

  def base(type, record, title:, subtitle:, content:, url:, local_path:, destination_label:, occurred_at:)
    now = Time.current
    {
      record_type: type,
      record_id: record.id,
      title: title.to_s.presence || "Untitled",
      subtitle: subtitle.to_s,
      content: content.to_s,
      url: url.to_s,
      local_path: local_path,
      destination_label: destination_label,
      occurred_at: occurred_at,
      created_at: now,
      updated_at: now
    }
  end

  def news_document(item)
    label = case item.item_type
            when "video" then "Watch source"
            when "podcast", "audio" then "Listen to source"
            else "Read source"
            end
    base("news", item,
      title: item.title,
      subtitle: item.item_type,
      content: item.body,
      url: item.url,
      local_path: "/i/#{item.id}",
      destination_label: label,
      occurred_at: item.published_at)
  end

  def partner_document(company)
    base("partner", company,
      title: company.name,
      subtitle: "Partner",
      content: [ company.alias, company.notes, company.city, company.state, company.country,
                 company.products, company.services, company.build_level, company.consulting_level,
                 company.reseller_level, company.service_provider_level, company.partner_level ].compact.join(" "),
      url: company.website,
      local_path: "/p/#{company.id}",
      destination_label: "Open partner profile",
      occurred_at: company.updated_at)
  end

  def application_document(app)
    base("application", app,
      title: app.title,
      subtitle: [ app.company_name, app.app_type ].compact.join(" · "),
      content: [ app.tagline, app.store_description, app.key_features, app.business_challenge,
                 app.system_requirements, app.company_name, app.app_type ].compact.join(" "),
      url: app.landing_page,
      local_path: "/a/#{app.id}",
      destination_label: "Open application",
      occurred_at: app.updated_at)
  end

  def financial_document(financial)
    base("financial", financial,
      title: financial.company_name.presence || financial.investment_type.presence || "Financial activity",
      subtitle: [ financial.investment_type, financial.date&.strftime("%Y") ].compact.join(" · "),
      content: [ financial.summary, financial.content, financial.people, financial.amount, financial.currency ].compact.join(" "),
      url: financial.url,
      local_path: "/financials?search=#{CGI.escape(financial.company_name.to_s)}",
      destination_label: "Open financial record",
      occurred_at: financial.date)
  end

  def event_document(session)
    base("event", session,
      title: session.title,
      subtitle: [ session.event_name, session.code ].compact.join(" · "),
      content: [ session.abstract, session.participants, session.times ].compact.join(" "),
      url: session.primary_url,
      local_path: if session.event_short_code.present?
                    "/e/#{CGI.escape(session.event_short_code.to_s)}?search=#{CGI.escape(session.title.to_s)}"
                  else
                    "/e?search=#{CGI.escape(session.title.to_s)}"
                  end,
      destination_label: "View session",
      occurred_at: session.modified || session.created_at)
  end

  def mvp_document(participant, awards)
    base("mvp", participant,
      title: participant.name,
      subtitle: "MVP",
      content: [ participant.title, participant.company_name, awards.map(&:year), awards.map(&:award_type) ].flatten.join(" "),
      url: nil,
      local_path: "/mvps?search=#{CGI.escape(participant.name.to_s)}",
      destination_label: "View MVP record",
      occurred_at: awards.max_by(&:year)&.created_at)
  end

  def connection
    ActiveRecord::Base.connection
  end
end
