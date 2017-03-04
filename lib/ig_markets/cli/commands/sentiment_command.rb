module IGMarkets
  module CLI
    # Implements the `ig_markets sentiment` command.
    class Main
      desc 'sentiment MARKET', 'Prints sentiment and related sentiments for the specified market'

      def sentiment(market)
        self.class.begin_session(options) do |dealing_platform|
          client_sentiment = dealing_platform.client_sentiment[market]
          client_sentiments = [client_sentiment, :separator, client_sentiment.related_sentiments]

          table = Tables::ClientSentimentsTable.new client_sentiments, title: "Client sentiment for '#{market}'"

          puts table
        end
      end
    end
  end
end
