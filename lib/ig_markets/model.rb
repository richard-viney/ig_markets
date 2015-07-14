module IGMarkets
  class Model
    include ActiveAttr::Model

    def deep_attributes_hash
      attributes.each_with_object({}) do |(k, v), new_hash|
        new_hash[k.to_sym] = v.is_a?(IGMarkets::Model) ? v.deep_attributes_hash : v
      end
    end
  end
end
