module IGMarkets
  module CLI
    # Implements the `ig_markets sentiment` command.
    class Main
      desc 'sentiment <MARKET>', 'Prints sentiment for the specified market'

      option :related, aliases: '-r', type: :boolean, desc: 'Whether to print sentiment for related markets as well'

      def sentiment(market)
        self.class.begin_session(options) do |dealing_platform|
          client_sentiment = dealing_platform.client_sentiment[market]

          Output.print_client_sentiment client_sentiment

          if options[:related]
            client_sentiment.related_sentiments.each do |model|
              Output.print_client_sentiment model
            end
          end
        end
      end
    end
  end
end
