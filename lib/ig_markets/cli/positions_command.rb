module IGMarkets
  module CLI
    # Implements the `ig_markets positions` command.
    class Main
      desc 'positions', 'Prints open positions'

      def positions
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.positions.all.each do |position|
            Output.print_position position
          end
        end
      end
    end
  end
end
