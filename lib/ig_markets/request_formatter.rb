module IGMarkets
  # This class contains methods for formatting a REST request and its response for inspection and debugging.
  #
  # @private
  class RequestFormatter
    class << self
      # Formats a request options hash that is ready to be passed to `Excon`.
      #
      # @param [Hash] options The request options.
      #
      # @return [String] The formatted request.
      def format_request(options)
        result = "#{options[:method].to_s.upcase} #{options[:url]}\n"

        result += format_request_headers options[:headers]
        result += format_request_body options[:body]

        result
      end

      # Formats a response received from `Excon`.
      #
      # @param [#headers, #body] response The response.
      #
      # @return [String] The formatted response.
      def format_response(response)
        result = "  Response:\n"

        result += format_response_headers response.headers
        result += format_response_body response.body

        result
      end

      private

      def format_request_headers(headers)
        result = "  Headers:\n"

        headers.each do |name, value|
          result += "    #{name}: #{value}\n"
        end

        result
      end

      def format_request_body(body)
        return '' if body.nil?

        result = "  Body:\n    "
        result += JSON.pretty_generate(JSON.parse(body)).gsub("\n", "\n    ")

        "#{result}\n"
      end

      def format_response_headers(headers)
        result = "    Headers:\n"

        headers.each do |name, value|
          result += "      #{name}: #{value}\n"
        end

        result
      end

      def format_response_body(body)
        result = "    Body:\n      "
        result += JSON.pretty_generate(JSON.parse(body)).gsub "\n", "\n      "
        "#{result}\n"
      rescue JSON::ParserError
        "#{result}#{body}\n"
      end
    end
  end
end
