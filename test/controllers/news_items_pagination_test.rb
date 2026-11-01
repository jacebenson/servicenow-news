require "test_helper"

class NewsItemsPaginationTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    @person = Participant.create!(name: "Pagination Person", hidden: false)
    @items = 30.times.map do |i|
      item = NewsItem.create!(title: "Pagination story #{i}", url: "https://example.com/pagination/#{i}",
                              active: true, published_at: i.days.ago)
      item.participants << @person
      item
    end
    NewsItem.create!(title: "Unrelated story", url: "https://example.com/unrelated", active: true, published_at: Time.current)
  end

  test "page two and next stay on HTML with distinct articles and working previous links" do
    get items_path
    assert_response :success
    assert_select "nav a[href='/i?page=2']", text: "2"
    assert_select "nav a[rel=next][href='/i?page=2']"
    first_titles = css_select("article h3").map(&:text)

    get css_select("nav a[rel=next]").first["href"]
    assert_response :success
    assert_equal "text/html", response.media_type
    assert_select "h1", text: /ServiceNow intelligence/
    assert_select "link[rel=stylesheet]"
    second_titles = css_select("article h3").map(&:text)
    assert_equal 6, second_titles.size
    assert_empty first_titles & second_titles
    previous = css_select("nav a[rel=prev]").first["href"]
    assert_equal "/i", previous
    get previous
    assert_equal first_titles, css_select("article h3").map(&:text)
  end

  test "search and participant filters survive pagination from each HTML route" do
    [ items_path(search: "Pagination story", participant: @person.slug),
      items_search_path(search: "Pagination story", participant: @person.slug),
      items_by_participant_path(participant: @person.slug, search: "Pagination story"),
      items_search_alt_path(search: "Pagination story", participant: @person.slug) ].each do |path|
      get path
      assert_response :success
      next_url = css_select("nav a[rel=next]").first["href"]
      uri = URI.parse(next_url)
      route = Rails.application.routes.recognize_path(uri.path).stringify_keys
      assert_equal "news_items", route.delete("controller")
      assert_equal "index", route.delete("action")
      assert_nil route["format"]
      assert_equal({ "page" => "2", "search" => "Pagination story", "participant" => @person.slug }, route.merge(Rack::Utils.parse_query(uri.query)))
      assert_select "nav a", text: "2" do |links|
        assert_equal next_url, links.first["href"]
      end
      get next_url
      assert_response :success
      assert_equal "text/html", response.media_type
      assert_equal 5, css_select("article").size
      assert_no_match "Unrelated story", response.body
      get css_select("nav a[rel=prev]").first["href"]
      assert_response :success
      assert_equal 25, css_select("article").size
    end
  end

  test "RSS still returns an unpaginated feed" do
    get feed_path, params: { page: 2 }
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
    assert_select "rss channel item", count: 31
  end
end
