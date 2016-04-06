module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints recent activities'

      option :days, default: 3, type: :numeric, desc: 'The number of days to print recent activities for'

      def activities
        begin_session do
          dealing_platform.account.recent_activities(seconds).each do |activity|
            print_activity activity
          end
        end
      end

      private

      def seconds
        (options[:days].to_f * 60 * 60 * 24).to_i
      end

      def print_activity(activity)
        print <<-END
#{activity.deal_id}: \
#{activity.size} of #{activity.epic}, \
level: #{activity.level}, \
result: #{activity.result}
END
      end
    end
  end
end
