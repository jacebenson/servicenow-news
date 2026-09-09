require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  self.fixture_table_names = []

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
