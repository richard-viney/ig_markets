module IGMarkets
  # Contains methods for parsing responses received from the IG Markets API.
  module ResponseParser
    module_function

    # Parses the passed JSON string and then passes it on to {parse}. If `json` is not valid JSON then `{}` is returned.
    #
    # @param [String] json The JSON string.
    #
    # @return [Hash]
    def parse_json(json)
      parse JSON.parse(json)
    rescue JSON::ParserError
      {}
    end

    # Parses the specified value that was returned from a call to the IG Markets API.
    #
    # @param [Hash, Array, Object] response The response or part of a reponse that should be parsed. If this is of type
    #        `Hash` then all hash keys will converted from camel case into snake case and their values each to parsed
    #        individually by a recursive call. If this is of type `Array` then each item will be parsed indidiaully by a
    #        recursive call. All other types are passed through unchanged.
    #
    # @return [Hash, Array, Object] The parsed object, the type depends on the type of the `response` parameter.
    def parse(response)
      if response.is_a? Hash
        response.each_with_object({}) do |(key, value), new_hash|
          new_hash[camel_case_to_snake_case(key).downcase.to_sym] = parse(value)
        end
      elsif response.is_a? Array
        response.map { |item| parse item }
      else
        response
      end
    end

    # Converts a camel case string to a snake case string.
    #
    # @param [String, Symbol] camel_case The camel case `String` or `Symbol` to convert to snake case.
    #
    # @return [String]
    def camel_case_to_snake_case(camel_case)
      camel_case.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z])([a-z])/, '\1_\2\3')
    end
  end
end
