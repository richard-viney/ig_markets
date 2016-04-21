module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::Activity} instances in a table.
    class ActivitiesTable < Table
      private

      def default_title
        'Activities'
      end

      def headings
        ['Date', 'Deal ID', 'EPIC', 'Size', 'Level', 'Result']
      end

      def right_aligned_columns
        [4]
      end

      def row(activity)
        [
          activity.date.strftime('%F'),
          activity.deal_id,
          activity.epic,
          activity.size,
          activity.level,
          activity.result
        ]
      end
    end
  end
end
