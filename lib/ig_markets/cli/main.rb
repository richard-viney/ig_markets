module IGMarkets
  # This module contains the code for the CLI frontend. See `README.md` for usage details.
  module CLI
    # Implements the `ig_markets` command-line client.
    class Main < Thor
      class_option :username, required: true, desc: 'The username for the session'
      class_option :password, required: true, desc: 'The password for the session'
      class_option :api_key, required: true, desc: 'The API key for the session'
      class_option :demo, type: :boolean, desc: 'Use the demo platform (default is production)'
      class_option :print_requests, type: :boolean, desc: 'Whether to print the raw REST API requests and responses'

      desc 'orders [SUBCOMAND=list ...]', 'Command for working with orders'
      subcommand 'orders', Orders

      desc 'positions [SUBCOMAND=list ...]', 'Command for working with positions'
      subcommand 'positions', Positions

      desc 'sprints [SUBCOMAND=list ...]', 'Command for working with sprint market positions'
      subcommand 'sprints', Sprints

      desc 'watchlists [SUBCOMAND=list ...]', 'Command for working with watchlists'
      subcommand 'watchlists', Watchlists

      class << self
        # This is the initial entry point for the execution of the command-line client. It is responsible for reading
        # any config files, implementing the --version/-v options, and then invoking the main application.
        #
        # @param [Array<String>] argv The array of command-line arguments.
        def bootstrap(argv)
          config_file.prepend_arguments_to_argv argv

          if argv.index('--version') || argv.index('-v')
            puts VERSION
            exit
          end

          start argv
        end

        # Signs in to IG Markets and yields back a {DealingPlatform} instance, with common error handling if exceptions
        # occur. This method is used by all of the commands in order to authenticate.
        #
        # @param [Thor::CoreExt::HashWithIndifferentAccess] options The Thor options hash.
        def begin_session(options)
          platform = options[:demo] ? :demo : :production

          RequestPrinter.enabled = true if options[:print_requests]

          @dealing_platform ||= DealingPlatform.new
          @dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield @dealing_platform
        rescue IGMarkets::RequestFailedError => error
          error "Request error: #{error.error}"
        rescue ArgumentError => error
          error "Argument error: #{error}"
        end

        # Requests and displays the deal confirmation for the passed deal reference. If the first request for the deal
        # confirmation returns a 'deal not found' error then the request is attempted again after a five second pause.
        # This is done because sometimes there is a delay in the processing of the deal by IG Markets.
        #
        # @param [String] deal_reference The deal reference.
        def report_deal_confirmation(deal_reference)
          puts "Deal reference: #{deal_reference}"

          print_deal_confirmation @dealing_platform.deal_confirmation(deal_reference)
        rescue RequestFailedError => request_failed_error
          raise unless request_failed_error.error == 'error.confirms.deal-not-found'

          puts 'Deal confirmation not found, pausing for five seconds before retrying ...'

          sleep 5
          print_deal_confirmation @dealing_platform.deal_confirmation(deal_reference)
        end

        # Parses and validates a `Date` or `Time` option received as a command-line argument. Raises `ArgumentError` if
        # it is been specified in an invalid format.
        #
        # @param [Hash] attributes The attributes hash.
        # @param [Symbol] attribute The name of the date or time attribute to parse and validate.
        # @param [Date, Time] klass The class to validate with.
        # @param [String] format The `strptime` format string for the attribute.
        # @param [String] display_format The human-readable version of `format` to put into the raised exception if
        #                 there is a problem parsing the attribute.
        def parse_date_time(attributes, attribute, klass, format, display_format)
          return unless attributes.key? attribute

          if !['', attribute.to_s].include? attributes[attribute].to_s
            begin
              attributes[attribute] = klass.strptime attributes[attribute], format
            rescue ArgumentError
              raise ArgumentError, "invalid #{attribute}, use format \"#{display_format}\""
            end
          else
            attributes[attribute] = nil
          end
        end

        # Takes a Thor options hash and filters out its keys in the specified whitelist. Thor has an unusual behavior
        # when an option is specified without a value: its value is set to the option's name. This method resets any
        # such occurrences to `nil`.
        #
        # @param [Thor::CoreExt::HashWithIndifferentAccess] options The Thor options.
        # @param [Array<Symbol>] whitelist The list of options allowed in the returned `Hash`.
        #
        # @return [Hash]
        def filter_options(options, whitelist)
          options.each_with_object({}) do |(key, value), new_hash|
            next unless whitelist.include? key.to_sym

            new_hash[key.to_sym] = (value == key) ? nil : value
          end
        end

        private

        # Writes the passed message to `stderr` and then exits the application.
        #
        # @param [String] message The error message.
        def error(message)
          warn message
          exit 1
        end

        # Returns the config file to use for this invocation.
        #
        # @return [ConfigFile]
        def config_file
          ConfigFile.find "#{Dir.pwd}/.ig_markets", "#{Dir.home}/.ig_markets"
        end

        # Prints out details of the passed deal confirmation.
        #
        # @param [DealConfirmation] deal_confirmation The deal confirmation to print out.
        def print_deal_confirmation(deal_confirmation)
          puts <<-END
Deal ID: #{deal_confirmation.deal_id}
Status: #{Format.symbol deal_confirmation.deal_status}
Result: #{Format.symbol deal_confirmation.status}
END

          puts "Reason: #{Format.symbol deal_confirmation.reason}" unless deal_confirmation.deal_status == :accepted
        end
      end
    end
  end
end
