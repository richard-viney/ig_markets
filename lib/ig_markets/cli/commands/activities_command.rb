module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints account activities'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account activities for'
      option :from, desc: 'The start date to print account activities from, format: yyyy-mm-dd'
      option :sort_by, enum: %w(channel date epic type), default: 'date', desc: 'The attribute to sort activities by'

      def activities
        self.class.begin_session(options) do |dealing_platform|
          activities = gather_activities dealing_platform

          table = ActivitiesTable.new activities

          puts table
        end
      end

      private

      def gather_activities(dealing_platform)
        gather_account_history(:activities, dealing_platform).sort_by do |activity|
          [activity.send(activity_sort_attribute), activity.date]
        end
      end

      def activity_sort_attribute
        {
          'channel' => :channel,
          'date' => :date,
          'epic' => :epic,
          'type' => :transaction_type
        }.fetch options[:sort_by]
      end

      def gather_account_history(method_name, dealing_platform)
        history_options = if options[:from]
                            from = Date.strptime options[:from], '%F'
                            to = from + options[:days]

                            { from: from, to: to }
                          else
                            { days: options[:days] }
                          end

        dealing_platform.account.send method_name, history_options
      end
    end
  end
end
