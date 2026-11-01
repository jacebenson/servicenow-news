require "test_helper"

class KnowledgeSessionsHelperTest < ActionView::TestCase
  self.fixture_table_names = []

  test "event routes retain list, export, and pagination options" do
    %w[k20 k21 k22 k23 k24 k25 k26 nulledge25].each do |event|
      assert_equal "/#{event}?page=2", event_sessions_path(event, page: 2)
      assert_equal "/#{event}/export.csv?search=example", event_sessions_export_path(event, search: "example", format: :csv)
      assert_equal "/#{event}/export.csv?search=example", event_sessions_export_path(event, { search: "example" }, format: :csv)
      assert_equal "/#{event}/export.csv?search=example", event_sessions_export_path(event, { search: "example" }.with_indifferent_access, format: :csv)
      assert_equal "/#{event}/list/mine", event_sessions_list_path(event, list: "mine")
    end
    assert_equal "/sessions?page=2", event_sessions_path("all", page: 2)
  end

  test "event values cannot select arbitrary methods" do
    [ "destroy", "send", "k26_path", "../../admin", nil ].each do |event|
      assert_raises(ActionController::RoutingError) { event_sessions_path(event) }
      assert_raises(ActionController::RoutingError) { event_sessions_export_path(event) }
      assert_raises(ActionController::RoutingError) { event_sessions_list_path(event) }
    end
  end
end
