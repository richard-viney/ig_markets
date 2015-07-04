module IGMarkets
  class Position
    include ActiveAttr::Model

    attribute :contract_size
    attribute :controlled_risk
    attribute :created_date, type: DateTime
    attribute :currency
    attribute :deal_id
    attribute :deal_size
    attribute :direction
    attribute :limit_level
    attribute :open_level
    attribute :stop_level
    attribute :trailing_step
    attribute :trailing_stop_distance

    attribute :market

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
