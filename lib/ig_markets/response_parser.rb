module IGMarkets
  # Contains methods for parsing responses received from the IG Markets API.
  #
  # @private
  module ResponseParser
    module_function

    # Parses the specified value that was returned from a call to the IG Markets API.
    #
    # @param [Hash, Array, Object] response The response or part of a response that should be parsed. If this is of type
    #        `Hash` then all hash keys will converted from camel case into snake case and their values will each be
    #        parsed individually by a recursive call. If this is of type `Array` then each item will be parsed
    #        individually by a recursive call. All other types are passed through unchanged.
    #
    # @return [Hash, Array, Object] The parsed object, the type depends on the type of the `response` parameter.
    def parse(response)
      case response
      when Hash
        response.each_with_object({}) do |(key, value), new_hash|
          new_hash[camel_case_to_snake_case(key).to_sym] = parse(value)
        end
      when Array
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
      camel_case.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z])([a-z])/, '\1_\2\3').downcase
    end
  end
end
