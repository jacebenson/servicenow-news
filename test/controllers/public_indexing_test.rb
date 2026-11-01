require "test_helper"

class PublicIndexingTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    @partner = Company.create!(name: "Public Indexing Partner", is_partner: true, active: true, country: "Denmark")
    @person = Participant.create!(name: "Public Indexing Person", hidden: false, company: @partner)
    @item = NewsItem.create!(title: "Public indexing article", url: "https://example.com/indexing", body: "Useful article content", active: true)
  end

  test "canonical URLs strip tracking and preserve real pagination" do
    get partner_path(@partner), params: { ref: "indiepage", utm_source: "example" }
    assert_response :success
    assert_select "link[rel=canonical][href='https://news.jace.pro/p/#{@partner.id}']", count: 1
    assert_nil response.headers["X-Robots-Tag"]

    25.times { |i| NewsItem.create!(title: "Article #{i}", url: "https://example.com/#{i}", active: true) }
    get items_path, params: { page: 2, trk: "public_post-text" }
    assert_response :success
    assert_select "link[rel=canonical][href='https://news.jace.pro/i?page=2']", count: 1
  end

  test "filtered results remain usable but are not indexable" do
    get partners_path, params: { search: "Public Indexing", country: "Denmark", has_people: "true" }
    assert_response :success
    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    assert_select "meta[name=robots][content='noindex, follow']", count: 1
    assert_select "link[rel=canonical]", count: 0
    assert_select "a[href*='has_people=true'][rel=nofollow]"
    assert_select "a[href='#{partner_path(@partner)}']", count: 1
  end

  test "empty filter results return a real 404 with usable search UI" do
    get partners_path, params: { search: "No matching company" }
    assert_response :not_found
    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    assert_select "form[action='/p']", count: 1
    assert_match "No partners found", response.body
  end

  test "HTML status codes do not depend on the crawler Accept header" do
    [ "*/*", "text/html", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" ].each do |accept|
      get partners_path, params: { search: "zzzznonexistent123", has_people: "1" }, headers: { "Accept" => accept }
      assert_response :not_found
      assert_equal "text/html", response.media_type
      assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
      assert_match "No partners found", response.body

      get partners_path, params: { page: 2000 }, headers: { "Accept" => accept }
      assert_response :not_found
    end
  end

  test "empty event filters return 404 for relation and array pagination" do
    [ nil, "time" ].each do |sort|
      get k26_path, params: { search: "zzzznonexistent123", sort: sort }, headers: { "Accept" => "*/*" }
      assert_response :not_found
      assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
      assert_select "meta[name=robots][content='noindex, follow']", count: 1
    end
  end

  test "RSS feeds retain their status when search results are empty" do
    get feed_path, params: { search: "zzzznonexistent123" }
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end

  test "invalid and nonexistent pagination does not duplicate the first or last page" do
    [ "0", "-1", "banana", "999999999999999999999", [ "2" ] ].each do |page|
      get partners_path, params: { page: page }
      assert_response :not_found
    end
    get partners_path, params: { page: 2 }
    assert_response :not_found
    get k26_path, params: { page: 2000 }
    assert_response :not_found
    get k26_path, params: { all: "1" }
    assert_response :success
  end

  test "profile aliases permanently redirect to the public short URL" do
    get who_path(name: @person.slug), params: { ref: "old-link" }
    assert_redirected_to person_path(name: @person.slug)
    assert_response :moved_permanently
    follow_redirect!
    assert_response :success
    assert_select "link[rel=canonical][href='https://news.jace.pro/w/#{@person.slug}']"
    get person_path(name: @person.name)
    assert_response :moved_permanently
  end

  test "missing and hidden records do not redirect to unrelated content" do
    @person.update!(hidden: true)
    @partner.update!(active: false)
    @item.update!(active: false)
    [ person_path(name: @person.slug), person_path(name: "missing-profile"),
      items_by_participant_path(participant: "missing-profile"), partner_path(@partner),
      item_path(@item), "/unknown-page" ].each do |path|
      get path
      assert_response :not_found
    end
  end

  test "event aliases use canonical event routes and reject unknown events" do
    get events_path
    assert_response :moved_permanently
    assert_redirected_to sessions_path
    get event_path(event: "k26"), params: { search: "example" }
    assert_redirected_to k26_path(search: "example")
    get event_path(event: "missing")
    assert_response :not_found
  end

  test "global search results are noindex and the homepage canonical ignores old pagination" do
    get search_path, params: { q: "example" }
    assert_response :success
    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    get root_path, params: { page: 1139, ref: "indiepage" }
    assert_select "link[rel=canonical][href='https://news.jace.pro/']"
  end
end
