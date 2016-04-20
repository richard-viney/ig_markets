module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::SprintMarketPosition} instances in a table.
    class SprintMarketPositionsTable < Table
      private

      def default_title
        'Sprint market positions'
      end

      def headings
        ['EPIC', 'Size', 'Strike level', 'Expires in (m:ss)', 'Payout', 'Deal ID']
      end

      def right_aligned_columns
        [1, 2, 3, 4]
      end

      def row(sprint)
        [
          sprint.epic,
          Format.currency(sprint.size, sprint.currency),
          Format.price(sprint.strike_level, sprint.currency),
          Format.seconds(sprint.seconds_till_expiry),
          Format.currency(sprint.payout_amount, sprint.currency),
          sprint.deal_id
        ]
      end
    end
  end
end
