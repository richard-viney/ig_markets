module IGMarkets
  class AccountBalance
    include ActiveAttr::Model

    attribute :available,   type: Float
    attribute :deposit,     type: Float
    attribute :profit_loss, type: Float
    attribute :available,   type: Float

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
