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
        # Signs in to IG Markets and yields back a {DealingPlatform} instance, with common error handling if exceptions
        # occur. This method is used by all of the commands in order to authenticate.
        #
        # @param [Thor::CoreExt::HashWithIndifferentAccess] options The Thor options hash.
        #
        # @return [void]
        def begin_session(options)
          platform = options[:demo] ? :demo : :production

          RequestPrinter.enabled = true if options[:print_requests]

          dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield dealing_platform
        rescue IGMarkets::RequestFailedError => error
          warn "Request error: #{error.error}"
          exit 1
        rescue ArgumentError => error
          warn "Argument error: #{error}"
          exit 1
        end

        # The dealing platform instance used by {begin_session}.
        def dealing_platform
          @dealing_platform ||= DealingPlatform.new
        end

        # Takes a deal reference and prints out its full deal confirmation.
        #
        # @param [String] deal_reference The deal reference.
        #
        # @return [void]
        def report_deal_confirmation(deal_reference)
          puts "Deal reference: #{deal_reference}"

          deal_confirmation = dealing_platform.deal_confirmation deal_reference

          print "Deal confirmation: #{deal_confirmation.deal_id}, #{deal_confirmation.deal_status}, "

          unless deal_confirmation.deal_status == :accepted
            print "reason: #{deal_confirmation.reason}, "
          end

          puts "epic: #{deal_confirmation.epic}"
        end

        # Parses and validates a Date or Time option received as a command-line argument. Raises `ArgumentError` if it
        # is been specified in an invalid format.
        #
        # @param [Hash] attributes The attributes hash.
        # @param [Symbol] attribute The name of the date or time attribute to parse and validate.
        # @param [Date, Time] klass The class to validate with.
        # @param [String] format The `strptime` format string for the attribute.
        # @param [String] display_format The human-readable version of `format` to put into an exception if there is
        #                 a problem parsing the attribute.
        #
        # @return [void]
        def parse_date_time(attributes, attribute, klass, format, display_format)
          return unless attributes.key? attribute

          if !['', attribute.to_s].include? attributes[attribute].to_s
            begin
              attributes[attribute] = klass.strptime attributes[attribute], format
            rescue ArgumentError
              raise "invalid #{attribute}, use format \"#{display_format}\""
            end
          else
            attributes[attribute] = nil
          end
        end

        # Takes a Thor options hash and filters out its keys in the specified whitelist. Thor has an unusual behavior
        # when an option is specified without a value: its value is set to the option's name. This method resets any
        # such occurrences to nil.
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

        # This is the initial entry point for the execution of the command-line client. It is responsible for reading
        # any config files, implementing the --version/-v options, and then invoking the main application.
        #
        # @param [Array<String>] argv The array of command-line arguments.
        #
        # @return [void]
        def bootstrap(argv)
          prepend_config_file_arguments argv

          if argv.index('--version') || argv.index('-v')
            puts VERSION
            exit
          end

          start argv
        end

        # Searches for a config file and if found inserts its arguments into the passed arguments array.
        #
        # @param [Array<String>] argv The array of command-line arguments.
        #
        # @return [void]
        def prepend_config_file_arguments(argv)
          config_file = ConfigFile.find

          return unless config_file

          insert_index = argv.index do |argument|
            argument[0] == '-'
          end || -1

          argv.insert insert_index, *config_file.arguments
        end
      end
    end
  end
end
