require "test_helper"

class PartnersControllerTest < ActionDispatch::IntegrationTest
  # These request tests create their own records rather than loading the legacy fixtures.
  self.fixture_table_names = []

  setup do
    @partner = Company.create!(name: "Indexing Test Partner", active: true,
      is_partner: true, country: "DK - Denmark")
    Participant.create!(name: "Indexing Test Person", company: @partner)
    Participant.create!(name: "Second Indexing Test Person", company: @partner)
    Company.create!(name: "Indexing Test Partner Without People", active: true,
      is_partner: true, country: "DK - Denmark")
  end

  test "search and has people filters render matching partners once" do
    get partners_path, params: { country: "DK - Denmark", has_people: "true", search: "Indexing Test Partner" }

    assert_response :success
    assert_select "a[href='#{partner_path(@partner)}']", count: 1
    assert_select "h3", text: "Indexing Test Partner Without People", count: 0
  end

  test "search and has people filters handle no matches" do
    get partners_path, params: { country: "DK - Denmark", has_people: "true", search: "Mondelez International" }

    assert_response :not_found
    assert_select "h3", count: 0
  end
end
