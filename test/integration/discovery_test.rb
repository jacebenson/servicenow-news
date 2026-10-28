require "test_helper"

class DiscoveryTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []
  PATHS = %w[/ /i /p /a /financials /e /mvps].freeze

  test "sitemap is bounded XML with only canonical public directories" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml", response.media_type
    xml = Nokogiri::XML(response.body) { |config| config.strict }
    assert_equal PATHS.map { |path| "https://news.jace.pro#{path}" }.sort,
      xml.xpath("//*[local-name()='loc']").map(&:text).sort
  end

  test "llms and robots link the real public discovery endpoints" do
    get "/llms.txt"
    assert_response :success
    assert_equal "text/plain", response.media_type
    PATHS.each { |path| assert_includes response.body, "https://news.jace.pro#{path}" }
    get "/robots.txt"
    assert_response :success
    assert_includes response.body, "Sitemap: https://news.jace.pro/sitemap.xml"
  end

  test "public directories have fixed host metadata and truthful schema" do
    host! "untrusted.example"
    PATHS.each do |path|
      get path
      assert_response :success
      assert_select "link[rel=canonical][href=?]", "https://news.jace.pro#{path}", count: 1
      assert_select "meta[name=description]" do |tags|
        assert tags.first["content"].present?
      end
      assert_select "title", text: /ServiceNow/
      assert_select 'script[type="application/ld+json"]' do |tags|
        schema = JSON.parse(tags.first.text)
        assert_includes %w[WebSite CollectionPage], schema.fetch("@type")
        assert_equal "https://news.jace.pro#{path}", schema.fetch("url")
        assert_nil schema["author"]
      end
    end
  end

  test "query variants and saved lists are not indexed" do
    %w[/i?page=2 /e?list=mine /k26/list/123 /login /signup /s?q=test].each do |path|
      get path
      assert_response :success
      assert_select "meta[name=robots][content='noindex, follow']", count: 1
      assert_select "link[rel=canonical]", count: 0
      assert_select 'script[type="application/ld+json"]', count: 0
    end
    %w[/admin /account /api/companies/search /k26/export.csv].each do |path|
      route = Rails.application.routes.recognize_path(path)
      refute_includes PATHS, path
      refute_equal "discovery", route[:controller]
    end
  end
end
