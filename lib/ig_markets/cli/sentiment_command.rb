module IGMarkets
  module CLI
    # Implements the `ig_markets sentiment` command.
    class Main
      desc 'sentiment', 'Prints sentiment for the specified market'

      option :market, aliases: '-m', required: true, desc: 'The name of the market to print sentiment for'
      option :related, aliases: '-r', type: :boolean, desc: 'Whether to print sentiment for related markets as well'

      def sentiment
        begin_session do
          result = dealing_platform.client_sentiment[options[:market]]

          print_sentiment result

          if options[:related]
            result.related_sentiments.each do |model|
              print_sentiment model
            end
          end
        end
      end

      private

      def print_sentiment(model)
        print <<-END
#{model.market_id}: \
longs: #{model.long_position_percentage}%, \
shorts: #{model.short_position_percentage}%
END
      end
    end
  end
end
