module IGMarkets
  module CLI
    # Implements the `ig_markets sentiment` command.
    class Main
      desc 'sentiment MARKET', 'Prints sentiment for the specified market'

      option :related, type: :boolean, desc: 'Whether to print sentiment for related markets as well'

      def sentiment(market)
        self.class.begin_session(options) do |dealing_platform|
          client_sentiments = [dealing_platform.client_sentiment[market]]

          client_sentiments += client_sentiments[0].related_sentiments if options[:related]

          table = ClientSentimentsTable.new client_sentiments

          puts table
        end
      end
    end
  end
end
