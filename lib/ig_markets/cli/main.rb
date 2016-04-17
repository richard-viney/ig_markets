module IGMarkets
  # This module contains the code for the CLI frontend. See `README.md` for usage details.
  module CLI
    # Implements the `ig_markets` command-line client.
    class Main < Thor
      class_option :username, required: true, desc: 'The username for the session'
      class_option :password, required: true, desc: 'The password for the session'
      class_option :api_key, required: true, desc: 'The API key for the session'
      class_option :demo, type: :boolean, desc: 'Use the demo platform (default is production)'

      desc 'orders [SUBCOMAND=list] ...', 'Command for working with orders'
      subcommand 'orders', Orders

      desc 'positions [SUBCOMAND=list] ...', 'Command for working with positions'
      subcommand 'positions', Positions

      desc 'sprints [SUBCOMAND=list] ...', 'Command for working with sprint market positions'
      subcommand 'sprints', Sprints

      desc 'watchlists [SUBCOMAND=list] ...', 'Command for working with watchlists'
      subcommand 'watchlists', Watchlists

      private

      class << self
        # Signs in to IG Markets and yields back an {DealingPlatform} instance, with common error handling if exceptions
        # occur. This method is used by all of the CLI commands to authenticate.
        #
        # @param [Thor::CoreExt::HashWithIndifferentAccess] options The Thor options hash.
        #
        # @return [void]
        def begin_session(options)
          platform = options[:demo] ? :demo : :production

          dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield dealing_platform
        rescue IGMarkets::RequestFailedError => error
          warn "Request failed: #{error.error}"
          exit 1
        rescue StandardError => error
          warn "Error: #{error}"
          exit 1
        end

        # The dealing platform instance used by {begin_session}.
        def dealing_platform
          @dealing_platform ||= DealingPlatform.new
        end

        # Parses and validates a Date or Time option received on the command line. Raises `ArgumentError` if the
        # attribute has been specified in an invalid format.
        #
        # @param [Hash] attributes The attributes hash.
        # @param [Symbol] attribute The name of the date or time attribute to parse and validate.
        # @param [Date, Time] klass The class to validate with.
        # @param [String] format The `strptime` format string to parse the attribute with.
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
      end
    end
  end
end
