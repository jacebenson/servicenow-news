require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    SearchDocument.delete_all
    now = Time.current
    SearchDocument.create!(
      record_type: "partner", record_id: 1, title: "Moveworks", subtitle: "Partner",
      content: "Employee workflow platform", local_path: "/p/1",
      destination_label: "Open partner profile", occurred_at: now
    )
    ActiveRecord::Base.connection.execute("INSERT INTO search_documents_fts(search_documents_fts) VALUES('rebuild')")
  end

  test "search renders grouped results and preserves the query" do
    get search_path(q: "Moveworks")

    assert_response :success
    assert_includes response.body, "Moveworks"
    assert_includes response.body, "Open partner profile"
    assert_includes response.body, "q=Moveworks"
  end

  test "search renders a useful empty state" do
    get search_path(q: "not-in-index")

    assert_response :success
    assert_includes response.body, "Nothing in the local index matched that."
    assert_includes response.body, "not-in-index"
  end
end
