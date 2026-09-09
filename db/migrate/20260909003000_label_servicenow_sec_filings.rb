class LabelServicenowSecFilings < ActiveRecord::Migration[8.0]
  SEC_TYPES = [ "Annual Report", "Quarterly Report", "Major Event Report" ].freeze

  def up
    ServicenowInvestment
      .where(investment_type: SEC_TYPES, company_name: [ nil, "" ])
      .update_all(company_name: "ServiceNow", updated_at: Time.current)
  end

  def down
    # The original records did not carry a company name. Keep the repair intact
    # if the migration is rolled back; removing it would recreate the bad UI.
  end
end
