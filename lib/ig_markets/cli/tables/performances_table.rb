module IGMarkets
  module CLI
    # Helper class that prints out account performance details in a table.
    class PerformancesTable < Table
      private

      def default_title
        'Dealing performance'
      end

      def headings
        ['EPIC', '# of closed deals', 'Profit/loss']
      end

      def right_aligned_columns
        [1, 2]
      end

      def row(model)
        [model[:epic], model[:transactions].size,
         Format.currency(model[:profit_loss], model[:transactions].first.currency)]
      end

      def cell_color(value, _transaction, _row_index, column_index)
        return unless headings[column_index] == 'Profit/loss'

        if value =~ /-/
          :red
        else
          :green
        end
      end
    end
  end
end
