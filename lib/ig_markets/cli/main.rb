module IGMarkets
  # This module contains the code for the CLI frontend. See `README.md` for usage details.
  module CLI
    # Implements the `ig_markets` command-line client.
    class Main < Thor
      class_option :username, aliases: '-u', required: true, desc: 'The username for the session'
      class_option :password, aliases: '-p', required: true, desc: 'The password for the session'
      class_option :api_key, aliases: '-k', required: true, desc: 'The API key for the session'
      class_option :demo, aliases: '-d', type: :boolean, desc: 'Use the demo platform (default is production)'

      no_commands do
        # Intercepts calls to `print` in the CLI commands, used by the test suite.
        def print(string)
          Kernel.print string
        end

        # Intercepts calls to `exit` in the CLI commands, used by the test suite.
        def exit(code)
          Kernel.exit code
        end

        def dealing_platform
          @dealing_platform ||= DealingPlatform.new
        end

        def begin_session
          platform = options[:demo] ? :demo : :production

          dealing_platform.sign_in options[:username], options[:password], options[:api_key], platform

          yield
        rescue IGMarkets::RequestFailedError => error
          print "ERROR: #{error.error}\n"
          exit 1
        end
      end
    end
  end
end
