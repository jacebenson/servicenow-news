require "test_helper"

class GlobalSearchTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    SearchDocument.delete_all
    now = Time.current
    SearchDocument.insert_all([
      document("news", 1, "Moveworks launch", "News", "The Moveworks story", "/i/1", "Read source", now),
      document("partner", 2, "Moveworks", "Partner", "Employee workflow platform", "/p/2", "Open partner profile", now - 1.day),
      document("financial", 3, "Moveworks", "Acquisition · 2025", "ServiceNow acquired Moveworks", "/f?search=Moveworks", "Open financial record", now - 2.days),
      document("news", 4, "Other story", "News", "This mentions Moveworks in the body", "/i/4", "Read source", now - 3.days)
    ], record_timestamps: false)
    connection.execute("INSERT INTO search_documents_fts(search_documents_fts) VALUES('rebuild')")
  end

  test "exact names rank ahead of content matches and group counts stay complete" do
    result = GlobalSearch.new(query: "Moveworks").call

    assert_equal 4, result[:total_count]
    assert_equal [ "Moveworks", "Moveworks" ], result[:exact_matches].map { |item| item[:title] }
    assert_equal 2, result[:groups]["news"][:count]
    assert_equal 2, result[:groups]["news"][:results].length
  end

  test "type filters only return the selected public group" do
    result = GlobalSearch.new(query: "Moveworks", type: "financial").call

    assert_equal 1, result[:total_count]
    assert_equal [ "financial" ], result[:groups].keys
  end

  test "empty and unknown searches return no results" do
    assert_equal 0, GlobalSearch.new(query: "").call[:total_count]
    assert_equal 0, GlobalSearch.new(query: "not-in-index").call[:total_count]
  end

  private

  def document(type, id, title, subtitle, content, path, label, occurred_at)
    {
      record_type: type, record_id: id, title: title, subtitle: subtitle,
      content: content, url: "", local_path: path, destination_label: label,
      occurred_at: occurred_at, created_at: occurred_at, updated_at: occurred_at
    }
  end

  def connection
    ActiveRecord::Base.connection
  end
end
