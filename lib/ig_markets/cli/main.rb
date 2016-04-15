module IGMarkets
  # This module contains the code for the CLI frontend. See `README.md` for usage details.
  module CLI
    # Implements the `ig_markets` command-line client.
    class Main < Thor
      class_option :username, aliases: '-u', required: true, desc: 'The username for the session'
      class_option :password, aliases: '-p', required: true, desc: 'The password for the session'
      class_option :api_key, aliases: '-k', required: true, desc: 'The API key for the session'
      class_option :demo, aliases: '-d', type: :boolean, desc: 'Use the demo platform (default is production)'

      desc 'sprints [SUBCOMAND=list] ...ARGS', 'Command for listing and creating sprint market positions'
      subcommand 'sprints', Sprints

      private

      def seconds
        (options[:days].to_f * 60 * 60 * 24).to_i
      end

      class << self
        def dealing_platform
          @dealing_platform ||= DealingPlatform.new
        end

        def begin_session(options)
          platform = options[:demo] ? :demo : :production

          dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield dealing_platform
        rescue IGMarkets::RequestFailedError => error
          puts "ERROR: #{error.error}"
          exit 1
        end
      end
    end
  end
end
