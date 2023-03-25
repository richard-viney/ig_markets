module IGMarkets
  module CLI
    # Implements the `ig_markets console` command.
    class Main < Thor
      desc 'console', "Logs in and opens a live Ruby console, the IGMarkets::DealingPlatform instance is named 'ig'"

      def console
        self.class.begin_session(options) do |dealing_platform|
          ig = dealing_platform

          pry binding # rubocop:disable Lint/Debugger
        end
      end
    end
  end
end
