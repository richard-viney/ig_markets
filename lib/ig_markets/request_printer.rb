module IGMarkets
  # This class contains methods for printing a REST request and its JSON response for inspection and debugging.
  # Request printing is enabled by setting {enabled} to `true`.
  #
  # @private
  class RequestPrinter
    class << self
      # Whether the request printer is enabled.
      #
      # @return [Boolean]
      attr_accessor :enabled

      # Prints out an options hash that is ready to be passed to `RestClient::Request.execute`.
      #
      # @param [Hash] options The options hash.
      def print_options(options)
        return unless enabled

        puts "#{options[:method].to_s.upcase} #{options[:url]}"

        puts '  Headers:'
        options[:headers].each do |name, value|
          print_request_header name, value
        end

        print_request_body options[:payload]
      end

      # Formats and prints a JSON response body.
      #
      # @param [String] body The response body.
      def print_response_body(body)
        return unless enabled

        print '  Response: '

        puts JSON.pretty_generate(JSON.parse(body)).gsub "\n", "\n            "
      rescue JSON::ParserError
        puts body
      end

      private

      def print_request_header(name, value)
        puts "    #{name.to_s.split('_').map { |h| h[0].upcase + h[1..-1] }.join('-')}: #{value}"
      end

      def print_request_body(body)
        return unless body

        print '  Body: '
        puts JSON.pretty_generate(JSON.parse(body)).gsub("\n", "\n        ")
      end
    end
  end
end
