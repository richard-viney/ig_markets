module IGMarkets
  module CLI
    module Tables
      # Helper class that prints out an array of {IGMarkets::Position} instances in a table. Positions that share an
      # EPIC can be aggregated into one row in the table if desired.
      class PositionsTable < Table
        def initialize(models, options = {})
          models = aggregated_positions(models) if options[:aggregate]

          super models, options
        end

        private

        def default_title
          'Positions'
        end

        def headings
          ['Date', 'EPIC', 'Type', 'Direction', 'Size', 'Level', 'Current', 'High', 'Low', 'Limit', 'Stop',
           'Profit/loss', 'Deal IDs']
        end

        def right_aligned_columns
          [4, 5, 6, 7, 8, 9, 10, 11]
        end

        def row(position)
          [position.created_date_utc, position.market.epic, position.market.instrument_type, position.direction,
           position.size, position_prices(position), profit_loss(position), position.deal_id]
        end

        def cell_color(value, _model, _row_index, column_index)
          return unless headings[column_index] == 'Profit/loss'

          if value =~ /-/
            :red
          else
            :green
          end
        end

        def position_prices(position)
          [
            position.level,
            position.close_level,
            position.market.high,
            position.market.low,
            position.limit_level,
            position.stop_level
          ].map do |value|
            Format.level value
          end
        end

        def profit_loss(position)
          Format.currency position.profit_loss, position.currency
        end

        def aggregated_positions(positions)
          grouped = positions.group_by do |position|
            position.market.epic
          end

          grouped.map do |_, group|
            group.size > 1 ? combine_positions(group) : group.first
          end
        end

        def combine_positions(positions)
          first = positions.first

          Position.new(contract_size: first.contract_size, currency: first.currency,
                       deal_id: combine_position_deal_ids(positions), direction: first.direction,
                       level: combine_position_levels(positions), market: first.market,
                       size: positions.map(&:size).reduce(:+)).tap do |combined|
            combined.level /= combined.size
          end
        end

        def combine_position_levels(positions)
          positions.map do |position|
            position.level * position.size
          end.reduce :+
        end

        def combine_position_deal_ids(positions)
          lines = []

          positions.map(&:deal_id).each_slice(2) do |deal_ids|
            lines << deal_ids.join(', ')
          end

          lines.join "\n"
        end
      end
    end
  end
end
