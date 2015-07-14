module IGMarkets
  module ResponseParser
    def parse(object)
      snake_case_hash_keys object
    end

    def snake_case_hash_keys(object)
      if object.is_a? Hash
        object.each_with_object({}) do |(k, v), new_hash|
          new_hash[k.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym] = snake_case_hash_keys(v)
        end
      elsif object.is_a? Enumerable
        object.map { |a| snake_case_hash_keys(a) }
      else
        object
      end
    end

    module_function :parse, :snake_case_hash_keys
  end
end
