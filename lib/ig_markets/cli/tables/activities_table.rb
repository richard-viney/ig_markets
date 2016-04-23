module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::Activity} instances in a table.
    class ActivitiesTable < Table
      private

      def default_title
        'Activities'
      end

      def headings
        %w(Date Time Channel Type Status EPIC Market Size Level Limit Stop Result)
      end

      def right_aligned_columns
        [7, 8, 9, 10]
      end

      def row(activity)
        [activity.date, activity.time, activity.channel, activity.activity, activity_status(activity), activity.epic,
         activity.market_name, activity.size, activity.level, activity.limit, activity.stop, activity.result]
      end

      def activity_status(activity)
        { accept: 'Accepted', reject: 'Rejected', manual: 'Manual', not_set: '' }.fetch activity.action_status
      end
    end
  end
end
