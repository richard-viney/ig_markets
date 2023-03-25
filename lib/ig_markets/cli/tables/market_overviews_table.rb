module IGMarkets
  module CLI
    module Tables
      # Helper class that prints out an array of {IGMarkets::MarketOverview} instances in a table.
      class MarketOverviewsTable < Table
        private

        def default_title
          'Markets'
        end

        def headings
          ['EPIC', 'Type', 'Instrument', 'Status', 'Expiry', 'Bid', 'Offer', 'High', 'Low', 'Change (net)',
           'Change (%)']
        end

        def right_aligned_columns
          [5, 6, 7, 8, 9, 10]
        end

        def row(market_overview)
          [market_overview.epic, market_overview.instrument_type, market_overview.instrument_name,
           market_overview.market_status, market_overview.expiry, levels(market_overview)]
        end

        def cell_color(value, _model, _row_index, column_index)
          return unless headings[column_index].include?('Change')

          if value.include?('-')
            :red
          else
            :green
          end
        end

        def levels(market_overview)
          %i[bid offer high low net_change percentage_change].map do |attribute|
            Format.level market_overview.send(attribute)
          end
        end
      end
    end
  end
end
