require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  test "sitemaps advertise only active public records at canonical URLs" do
    item = NewsItem.create!(title: "Sitemap article", url: "https://example.com/sitemap", active: true)
    inactive = NewsItem.create!(title: "Inactive article", url: "https://example.com/inactive", active: false)
    visible = Participant.create!(name: "Visible Person", hidden: false)
    hidden = Participant.create!(name: "Hidden Person", hidden: true)

    get "/sitemap.xml"
    assert_response :success
    index = Nokogiri::XML(response.body)
    assert_empty index.errors
    assert_includes index.xpath("//*[local-name()='loc']").map(&:text), "https://news.jace.pro/sitemaps/news-1.xml"

    get "/sitemaps/news-1.xml"
    assert_response :success
    assert_includes response.body, "https://news.jace.pro/i/#{item.id}"
    assert_not_includes response.body, "https://news.jace.pro/i/#{inactive.id}"
    assert_not_includes response.body, "search="

    get "/sitemaps/people-1.xml"
    assert_includes response.body, "https://news.jace.pro/w/#{visible.slug}"
    assert_not_includes response.body, hidden.slug

    get "/sitemaps/pages.xml"
    assert_response :success
    assert_includes response.body, "https://news.jace.pro/sessions"
    assert_not_includes response.body, "https://news.jace.pro/e<"
  end

  test "sitemap pages are bounded and unknown or empty partitions return 404" do
    now = Time.current
    NewsItem.insert_all!(Array.new(5_001) { |i| { title: "Article #{i}", url: "https://example.com/article/#{i}", active: true, created_at: now, updated_at: now } })
    get "/sitemaps/news-2.xml"
    assert_response :success
    assert_equal 1, Nokogiri::XML(response.body).xpath("//*[local-name()='url']").length
    [ "/sitemaps/news-3.xml", "/sitemaps/news-0.xml", "/sitemaps/secrets-1.xml" ].each do |path|
      get path
      assert_response :not_found
    end
  end
end
