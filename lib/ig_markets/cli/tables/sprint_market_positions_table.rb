module IGMarkets
  module CLI
    module Tables
      # Helper class that prints out an array of {IGMarkets::SprintMarketPosition} instances in a table.
      class SprintMarketPositionsTable < Table
        def initialize(sprints, options = {})
          super

          @markets = options.fetch :markets
        end

        private

        def default_title
          'Sprint market positions'
        end

        def headings
          ['EPIC', 'Direction', 'Size', 'Strike level', 'Current', 'Expires in (m:ss)', 'Payout', 'Deal ID']
        end

        def right_aligned_columns
          [2, 3, 4, 5]
        end

        def row(sprint)
          [sprint.epic, sprint.direction, Format.currency(sprint.size, sprint.currency), levels(sprint),
           Format.seconds(sprint.seconds_till_expiry), Format.currency(sprint.payout_amount, sprint.currency),
           sprint.deal_id]
        end

        def cell_color(_value, sprint, _row_index, column_index)
          return unless headings[column_index] == 'Payout'

          if (current_level(sprint) > sprint.strike_level && sprint.direction == :buy) ||
             (current_level(sprint) < sprint.strike_level && sprint.direction == :sell)
            :green
          else
            :red
          end
        end

        def levels(sprint)
          [Format.level(sprint.strike_level), Format.level(current_level(sprint))]
        end

        def current_level(sprint)
          snapshot = @markets.detect do |market|
            market.instrument.epic == sprint.epic
          end.snapshot

          (snapshot.bid + snapshot.offer) / 2.0
        end
      end
    end
  end
end
