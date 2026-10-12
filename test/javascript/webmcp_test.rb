require "test_helper"

class WebmcpJavascriptTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  TOOL_NAMES = %w[
    search_service_now
    search_news_items
    search_partners
    search_applications
    search_financial_activity
    search_mvp_awards
    search_people
    open_news_item
    open_application
    open_partner
    open_person
  ].freeze

  test "registers read-only tools for every public catalog" do
    source = Rails.root.join("app/javascript/webmcp.js").read

    assert_includes source, "document.modelContext.registerTool"
    assert_includes source, "readOnlyHint: true"
    TOOL_NAMES.each { |tool_name| assert_includes source, "name: \"#{tool_name}\"" }
  end

  test "is progressive enhancement when WebMCP is unavailable" do
    source = Rails.root.join("app/javascript/webmcp.js").read

    assert_includes source, "if (!window.isSecureContext || !document.modelContext?.registerTool) return;"
  end
end
