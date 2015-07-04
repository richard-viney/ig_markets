module IGMarkets
  class Activity
    include ActiveAttr::Model

    attribute :action_status
    attribute :activity
    attribute :activity_history_id
    attribute :channel
    attribute :currency
    attribute :date
    attribute :deal_id
    attribute :epic
    attribute :level
    attribute :limit
    attribute :market_name
    attribute :period
    attribute :result
    attribute :size
    attribute :stop
    attribute :stop_type
    attribute :time

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
