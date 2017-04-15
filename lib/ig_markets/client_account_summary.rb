module IGMarkets
  # Contains details on an IG Markets client account summary. Returned by {DealingPlatform#client_account_summary}.
  class ClientAccountSummary < Model
    # Contains details on a form, used by {#form_details}.
    class FormDetails < Model
      attribute :form_dismissable, Boolean
      attribute :form_title
      attribute :form_type, Symbol, allowed_values: %i[bca kyc]
      attribute :form_url
    end

    # Contains details on an account, used by {#accounts}.
    class AccountDetails < Model
      attribute :account_id
      attribute :account_name
      attribute :account_type, Symbol, allowed_values: %i[cfd physical spreadbet]
      attribute :preferred, Boolean
    end

    attribute :account_info, Account::Balance
    attribute :account_type, Symbol, allowed_values: %i[cfd physical spreadbet]
    attribute :accounts, AccountDetails
    attribute :authentication_status, Symbol, allowed_values: %i[authenticated authenticated_missing_credentials
                                                                 change_environment disabled_preferred_account
                                                                 missing_preferred_account
                                                                 rejected_invalid_client_version]
    attribute :client_id
    attribute :currency_iso_code, String, regex: Regex::CURRENCY
    attribute :currency_symbol
    attribute :current_account_id
    attribute :dealing_enabled, Boolean
    attribute :encrypted
    attribute :form_details, FormDetails
    attribute :has_active_demo_accounts, Boolean
    attribute :has_active_live_accounts, Boolean
    attribute :ig_company
    attribute :lightstreamer_endpoint
    attribute :rerouting_environment, Symbol, allowed_values: %i[demo live test uat]
    attribute :timezone_offset, Float
    attribute :trailing_stops_enabled, Boolean
  end
end
