module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::HistoricalPriceResult::Snapshot} instances in a table.
    class HistoricalPriceResultSnapshotsTable < Table
      private

      def headings
        %w(Date Open Close Low High)
      end

      def right_aligned_columns
        [1, 2, 3, 4]
      end

      def row(snapshot)
        [snapshot.snapshot_time_utc, format_price(snapshot.open_price), format_price(snapshot.close_price),
         format_price(snapshot.low_price), format_price(snapshot.high_price)]
      end

      def format_price(price)
        (price.ask + price.bid) / 2.0
      end
    end
  end
end
