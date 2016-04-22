module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::Position} instances in a table. Positions that share an EPIC
    # can be aggregated into one row in the table if desired.
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
        ['Date', 'EPIC', 'Direction', 'Size', 'Level', 'Current', 'Limit', 'Stop', 'Profit/loss', 'Deal IDs']
      end

      def right_aligned_columns
        [3, 4, 5, 6, 7, 8]
      end

      def row(position)
        [
          position_date(position),
          position.market.epic,
          position.direction.to_s.capitalize,
          position.size,
          position_prices(position),
          Format.currency(position.profit_loss, position.currency),
          position.deal_id
        ].flatten
      end

      def cell_color(value, _model, _row_index, column_index)
        return unless column_index == 8

        if value =~ /-/
          :red
        else
          :green
        end
      end

      def position_date(position)
        position.created_date_utc ? position.created_date_utc.strftime('%F %T %z') : ''
      end

      def position_prices(position)
        [:level, :close_level, :limit_level, :stop_level].map do |attribute|
          Format.level position.send(attribute)
        end
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
        end.reduce(:+)
      end

      def combine_position_deal_ids(positions)
        positions.map(&:deal_id).join(', ')
      end
    end
  end
end
