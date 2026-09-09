require "test_helper"

class FinancialsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    ServicenowInvestment.create!(investment_type: "Acquisition", company_name: "Acquisition company", date: Date.new(2026, 2, 11))
    ServicenowInvestment.create!(investment_type: "Investment", company_name: "Investment company", date: Date.new(2026, 2, 11))
  end

  test "public financials page renders the financial activity" do
    get financials_path

    assert_response :success
    assert_includes response.body, "ServiceNow intelligence"
    assert_includes response.body, "Acquisition company"
    assert_includes response.body, "Investment company"
  end

  test "financials can be filtered by activity type" do
    get financials_path, params: { type: "Acquisition" }

    assert_response :success
    assert_includes response.body, "Acquisition company"
    refute_includes response.body, "Investment company"
  end

  test "financials can be searched by company" do
    get financials_path, params: { search: "Investment company" }

    assert_response :success
    assert_includes response.body, "Investment company"
    refute_includes response.body, "Acquisition company"
  end
end
