module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints account activities'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account activities for'
      option :start_date, desc: 'The start date to print account activities from, format: yyyy-mm-dd'

      def activities
        self.class.begin_session(options) do |_dealing_platform|
          activities = gather_account_history(:activities).sort_by(&:date)

          table = ActivitiesTable.new activities

          puts table
        end
      end

      private

      def gather_account_history(type)
        days = options[:days]
        start_date = options[:start_date]

        send_args = if start_date
                      start_date = Date.strptime start_date, '%F'
                      end_date = start_date + days.to_i

                      ["#{type}_in_date_range", start_date, end_date]
                    else
                      ["recent_#{type}", days]
                    end

        Main.dealing_platform.account.send(*send_args)
      end
    end
  end
end
