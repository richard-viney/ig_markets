module IGMarkets
  class WorkingOrder
    include ActiveAttr::Model

    attribute :contingent_limit, type: Float
    attribute :contingent_stop, type: Float
    attribute :controlled_risk, type: Boolean
    attribute :created_date, type: DateTime
    attribute :currency_code
    attribute :deal_id
    attribute :direction
    attribute :dma, type: Boolean
    attribute :epic
    attribute :good_till
    attribute :level, type: Float
    attribute :request_type
    attribute :size, type: Float
    attribute :trailing_stop_distance, type: Float
    attribute :trailing_stop_increment, type: Float
    attribute :trailing_trigger_distance, type: Float
    attribute :trailing_trigger_increment, type: Float

    attribute :market

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
