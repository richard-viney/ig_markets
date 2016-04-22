module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::MarketOverview} instances in a table.
    class MarketOverviewsTable < Table
      private

      def default_title
        'Markets'
      end

      def headings
        ['Type', 'EPIC', 'Instrument', 'Status', 'Expiry', 'Bid', 'Offer', 'High', 'Low', 'Change (net)', 'Change (%)']
      end

      def right_aligned_columns
        [5, 6, 7, 8, 9, 10]
      end

      def row(market_overview)
        type = market_overview.instrument_type.to_s.capitalize.tr('_', ' ')

        [type, market_overview.epic, market_overview.instrument_name, market_status(market_overview),
         market_overview.expiry] + levels(market_overview)
      end

      def cell_color(value, _model, _row_index, column_index)
        if [9, 10].include? column_index
          if value =~ /-/
            :red
          else
            :green
          end
        end
      end

      def levels(market_overview)
        [:bid, :offer, :high, :low, :net_change, :percentage_change].map do |attribute|
          Format.level market_overview.send(attribute)
        end
      end

      def market_status(market_overview)
        { closed: 'Closed', edits_only: 'Edits only', offline: 'Offline', on_auction: 'On auction',
          on_auction_no_edits: 'On auction no edits', suspended: 'Suspended', tradeable: 'Tradeable'
        }.fetch market_overview.market_status
      end
    end
  end
end
