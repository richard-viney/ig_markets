module IGMarkets
  module ResponseParser
    module_function

    def parse(object)
      snake_case_hash_keys object
    end

    def snake_case_hash_keys(object)
      if object.is_a? Hash
        object.each_with_object({}) do |(key, value), new_hash|
          new_key = key.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z])([a-z])/, '\1_\2\3')
          new_hash[new_key.downcase.to_sym] = snake_case_hash_keys(value)
        end
      elsif object.is_a? Enumerable
        object.map { |item| snake_case_hash_keys item }
      else
        object
      end
    end
  end
end
