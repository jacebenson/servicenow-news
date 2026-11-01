require "test_helper"

class KnowledgeSessionsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "session pages render with explicit event routes" do
    get k26_path
    assert_response :success
    assert_select "a[href='#{k26_export_path(format: :csv)}']", count: 1

    get sessions_path
    assert_response :success
  end

  test "session export remains available" do
    get k26_export_path(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
  end
end
