module IGMarkets
  module CLI
    module Tables
      # Helper class that prints out account performance details in a table.
      class PerformancesTable < Table
        private

        def default_title
          'Dealing performance'
        end

        def headings
          ['EPIC', 'Instrument name', '# of closed deals', 'Profit/loss']
        end

        def right_aligned_columns
          [2, 3]
        end

        def row(model)
          transactions = model.fetch :transactions

          [model.fetch(:epic), model.fetch(:instrument_name), transactions.size,
           Format.currency(model.fetch(:profit_loss), transactions.first.currency)]
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
end
