module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::ClientSentiment} instances in a table.
    class ClientSentimentsTable < Table
      private

      def headings
        ['Market', 'Long %', 'Short %']
      end

      def right_aligned_columns
        [1, 2]
      end

      def row(client_sentiment)
        [
          client_sentiment.market_id,
          client_sentiment.long_position_percentage,
          client_sentiment.short_position_percentage
        ]
      end

      def cell_color(_value, client_sentiment, _row_index, _column_index)
        distance_from_center = (client_sentiment.long_position_percentage - 50.0).abs

        if distance_from_center > 35
          :red
        elsif distance_from_center > 20
          :yellow
        end
      end
    end
  end
end
