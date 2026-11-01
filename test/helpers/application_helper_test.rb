require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  self.fixture_table_names = []

  test "external URLs allow only absolute HTTP and HTTPS links" do
    assert_equal "https://example.com/path?a=1&b=2", safe_http_url("https://example.com/path?a=1&b=2")
    assert_equal "http://example.com", safe_http_url(" http://example.com ")

    [ nil, "javascript:alert(1)", "data:text/html,test", "//example.com", "/relative", "https://", "https://example.com/\nscript" ].each do |url|
      assert_equal "#", safe_http_url(url), "Unexpectedly allowed #{url.inspect}"
    end
  end

  test "formats large financial amounts compactly" do
    assert_equal "$3M", financial_amount("3000000", "USD")
    assert_equal "4.85B", financial_amount("4850000000")
    assert_equal "$125K", financial_amount("125000", "USD")
  end

  test "uses the supplied currency" do
    assert_equal "€2.5M", financial_amount("2500000", "EUR")
  end

  test "returns nil for a missing amount" do
    assert_nil financial_amount(nil)
  end
end
