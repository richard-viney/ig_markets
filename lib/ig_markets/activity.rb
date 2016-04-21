module IGMarkets
  # Contains details on a single activity that occurred on an IG Markets account. Returned by
  # {DealingPlatform::AccountMethods#activities_in_date_range} and
  # {DealingPlatform::AccountMethods#recent_activities}.
  class Activity < Model
    attribute :action_status, Symbol, allowed_values: [:accept, :reject, :manual, :not_set]
    attribute :activity
    attribute :activity_history_id
    attribute :channel
    attribute :currency
    attribute :date, Date, format: '%d/%m/%y'
    attribute :deal_id
    attribute :epic, String, regex: Regex::EPIC
    attribute :level, Float
    attribute :limit, Float, nil_if: '-'
    attribute :market_name
    attribute :period, String, nil_if: '-'
    attribute :result
    attribute :size
    attribute :stop, String, nil_if: '-'
    attribute :stop_type, String, nil_if: '-', allowed_values: %w(G N T(50))
    attribute :time
  end
end
