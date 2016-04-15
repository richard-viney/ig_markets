module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints recent activities'

      option :days, default: 3, type: :numeric, desc: 'The number of days to print recent activities for'

      def activities
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.account.recent_activities(seconds).each do |activity|
            Output.print_activity activity
          end
        end
      end
    end
  end
end
