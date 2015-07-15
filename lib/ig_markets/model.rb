module IGMarkets
  class Model
    include ActiveAttr::Model

    def self.from(attributes)
      attributes.is_a?(Hash) ? new(attributes) : attributes
    end
  end
end
