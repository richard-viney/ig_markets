module IGMarkets
  module ResponseParser
    module_function

    def parse(object)
      snake_case_hash_keys object
    end

    def snake_case_hash_keys(object)
      if object.is_a? Hash
        object.each_with_object({}) do |(k, v), new_hash|
          new_key = k.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z])([a-z])/, '\1_\2\3')
          new_hash[new_key.downcase.to_sym] = snake_case_hash_keys(v)
        end
      elsif object.is_a? Enumerable
        object.map { |a| snake_case_hash_keys a }
      else
        object
      end
    end
  end
end
