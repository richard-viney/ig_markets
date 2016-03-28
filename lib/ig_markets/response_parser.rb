module IGMarkets
  # Contains methods for parsing responses received from the IG Markets API.
  module ResponseParser
    module_function

    # Parses the specified value that was returned a call to the IG Markets API. This converts all hash keys from camel
    # case into conventional Ruby snake case. If an array is passed then each item will be parsed individually.
    def parse(object)
      if object.is_a? Hash
        object.each_with_object({}) do |(key, value), new_hash|
          new_hash[camel_case_to_snake_case(key).downcase.to_sym] = parse(value)
        end
      elsif object.is_a? Enumerable
        object.map { |item| parse item }
      else
        object
      end
    end

    # Converts a camel case string to a snake case string.
    #
    # @return [String]
    def camel_case_to_snake_case(camel_case)
      camel_case.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z])([a-z])/, '\1_\2\3')
    end
  end
end
