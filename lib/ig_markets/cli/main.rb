module IGMarkets
  # This module contains the code for the CLI frontend. See `README.md` for usage details.
  module CLI
    # Implements the `ig_markets` command-line client.
    class Main < Thor
      class_option :username, required: true, desc: 'The username for the session'
      class_option :password, required: true, desc: 'The password for the session'
      class_option :api_key, required: true, desc: 'The API key for the session'
      class_option :demo, type: :boolean, desc: 'Use the demo platform (default is the live platform)'
      class_option :verbose, type: :boolean, desc: 'Whether to print the raw REST API requests and responses'
      class_option :profile, desc: 'The name of the authentication profile to use (will be read from the config file)'

      desc 'orders [SUBCOMAND=list ...]', 'Command for working with orders'
      subcommand 'orders', Orders

      desc 'positions [SUBCOMAND=list ...]', 'Command for working with positions'
      subcommand 'positions', Positions

      desc 'sprints [SUBCOMAND=list ...]', 'Command for working with sprint market positions'
      subcommand 'sprints', Sprints

      desc 'stream [SUBCOMAND=dashboard ...]', 'Command for working with display of streaming data'
      subcommand 'stream', Stream

      desc 'watchlists [SUBCOMAND=list ...]', 'Command for working with watchlists'
      subcommand 'watchlists', Watchlists

      private

      # Turns the `:days` or `:from` options into a hash that can be passed to {AccountMethods#activities} and
      # {AccountMethods#transactions}.
      def history_options
        if options[:from]
          {
            from: history_options_parse_time(options[:from]),
            to: history_options_parse_time(options[:to])
          }
        else
          { from: Time.now.utc - (options[:days] * 86_400) }
        end
      end

      def history_options_parse_time(input)
        input && Time.strptime(input, '%FT%T%z')
      end

      class << self
        # This is the initial entry point for the execution of the command-line client. It is responsible for reading
        # any config files, implementing the --version/-v options, and then invoking the main application.
        #
        # @param [Array<String>] argv The array of command-line arguments.
        def bootstrap(argv)
          config_file.prepend_profile_arguments_to_argv argv unless argv.first == 'help'

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
          platform = options[:demo] ? :demo : :live

          @dealing_platform ||= DealingPlatform.new
          @dealing_platform.session.log_sinks = [$stdout] if options[:verbose]

          @dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield @dealing_platform
        rescue IGMarketsError => e
          warn_and_exit e
        end

        # Requests and displays the deal confirmation for the passed deal reference. If the request for the deal
        # confirmation returns a 'deal not found' error then the request is attempted again after a two second pause.
        # This is done because sometimes there is a delay in the processing of the deal by IG Markets. A maximum of
        # five attempts wil be made before failing outright.
        #
        # @param [String] deal_reference The deal reference.
        def report_deal_confirmation(deal_reference)
          puts "Deal reference: #{deal_reference}"

          5.times do |index|
            return print_deal_confirmation @dealing_platform.deal_confirmation(deal_reference)
          rescue Errors::DealNotFoundError
            raise if index == 4

            puts 'Deal not found, retrying ...'
            sleep 2
          end
        end

        # Parses and validates a `Date` or `Time` option received as a command-line argument. Raises `ArgumentError` if
        # it has been specified in an invalid format.
        #
        # @param [Hash] attributes The attributes hash.
        # @param [Symbol] attribute The name of the date or time attribute to parse and validate.
        # @param [Date, Time] klass The class to validate with.
        # @param [String] format The `strptime` format string for the attribute.
        # @param [String] display_format The human-readable version of `format` to put into the raised exception if
        #                 there is a problem parsing the attribute.
        def parse_date_time(attributes, attribute, klass, format, display_format)
          return unless attributes.key? attribute

          if ['', attribute.to_s].include? attributes[attribute].to_s
            attributes[attribute] = nil
          else
            begin
              attributes[attribute] = klass.strptime attributes[attribute], format
            rescue ArgumentError
              raise ArgumentError, %(invalid #{attribute}, use format "#{display_format}")
            end
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

            new_hash[key.to_sym] = value == key ? nil : value
          end
        end

        private

        # Prints the passed error to `stderr` and then exits the application.
        def warn_and_exit(error)
          class_name = error.class.name.split('::').last
          class_name = nil if class_name == 'IGMarketsError'

          message = error.message.to_s
          message = nil if ['', error.class.to_s].include? message

          warn "ig_markets: #{[class_name, message].compact.join ', '}"

          exit 1
        end

        # Returns the config file to use for this invocation.
        def config_file
          ConfigFile.find "#{Dir.pwd}/.ig_markets.yml", "#{Dir.home}/.ig_markets.yml"
        end

        # Prints out details of the passed deal confirmation.
        def print_deal_confirmation(deal_confirmation)
          puts <<~MSG
            Deal ID: #{deal_confirmation.deal_id}
            Status: #{Format.symbol deal_confirmation.deal_status}
            Result: #{Format.symbol deal_confirmation.status}
          MSG

          print_deal_confirmation_profit_loss deal_confirmation

          puts "Reason: #{Format.symbol deal_confirmation.reason}" unless deal_confirmation.deal_status == :accepted
        end

        # Prints out the profit/loss for the passed deal confirmation if applicable.
        def print_deal_confirmation_profit_loss(deal_confirmation)
          return unless deal_confirmation.profit

          puts "Profit/loss: #{Format.colored_currency deal_confirmation.profit, deal_confirmation.profit_currency}"
        end
      end
    end
  end
end
