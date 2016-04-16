module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints account activities'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account activities for'
      option :start_date, desc: 'The start date to print account activities from, in the format \'YYYY-MM-DD\''

      def activities
        self.class.begin_session(options) do |dealing_platform|
          gather_activities(dealing_platform, options[:days], options[:start_date]).sort_by(&:date).each do |activity|
            Output.print_activity activity
          end
        end
      end

      private

      def gather_activities(dealing_platform, days, start_date = nil)
        if start_date
          start_date = Date.strptime options[:start_date], '%F'

          dealing_platform.account.activities_in_date_range start_date, start_date + days.to_i
        else
          dealing_platform.account.recent_activities seconds(days)
        end
      end
    end
  end
end
