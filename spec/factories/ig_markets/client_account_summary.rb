FactoryGirl.define do
  factory :client_account_summary, class: IGMarkets::ClientAccountSummary do
    account_info { build :account_balance }
    account_type 'CFD'
    accounts { [build(:client_account_summary_account_details)] }
    authentication_status 'AUTHENTICATED'
    client_id 'CLIENT'
    currency_iso_code 'USD'
    currency_symbol '$'
    current_account_id 'ACCOUNT'
    dealing_enabled true
    encrypted true
    form_details { [build(:client_account_summary_form_details)] }
    has_active_demo_accounts true
    has_active_live_accounts true
    ig_company ''
    lightstreamer_endpoint 'http://lightstreamer.com'
    rerouting_environment :test
    timezone_offset 0
    trailing_stops_enabled false
  end

  factory :client_account_summary_form_details, class: IGMarkets::ClientAccountSummary::FormDetails do
    form_dismissable true
    form_title ''
    form_type 'KYC'
    form_url nil
  end

  factory :client_account_summary_account_details, class: IGMarkets::ClientAccountSummary::AccountDetails do
    account_id 'ACCOUNT'
    account_name 'Account name'
    account_type 'CFD'
    preferred true
  end
end
