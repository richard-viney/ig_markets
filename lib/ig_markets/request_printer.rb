module IGMarkets
  # This class contains methods for printing a REST request and its response for inspection and debugging. Request
  # printing is enabled by setting {enabled} to `true`.
  #
  # @private
  class RequestPrinter
    class << self
      # Whether the request printer is enabled.
      #
      # @return [Boolean]
      attr_accessor :enabled

      # Prints out a request options hash that is ready to be passed to `Excon`.
      #
      # @param [Hash] options The request options.
      def print_request(options)
        return unless enabled

        puts "#{options[:method].to_s.upcase} #{options[:url]}"

        print_request_headers options[:headers]
        print_request_body options[:body]
      end

      # Formats and prints a response received form `Excon`.
      #
      # @param [#headers, #body] response The response.
      def print_response(response)
        return unless enabled

        puts '  Response:'

        print_response_headers response.headers
        print_response_body response.body
      end

      private

      def print_request_headers(headers)
        puts '  Headers:'
        headers.each do |name, value|
          puts "    #{name}: #{value}"
        end
      end

      def print_request_body(body)
        return unless body

        print "  Body:\n    "
        puts JSON.pretty_generate(JSON.parse(body)).gsub("\n", "\n    ")
      end

      def print_response_headers(headers)
        puts '    Headers:'
        headers.each do |name, value|
          puts "      #{name}: #{value}"
        end
      end

      def print_response_body(body)
        print "    Body:\n      "
        puts JSON.pretty_generate(JSON.parse(body)).gsub "\n", "\n      "
      rescue JSON::ParserError
        puts body
      end
    end
  end
end
