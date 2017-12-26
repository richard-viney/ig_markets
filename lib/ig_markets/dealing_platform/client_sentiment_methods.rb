module IGMarkets
  class DealingPlatform
    # Provides methods for working with client sentiment. Returned by {DealingPlatform#client_sentiment}.
    class ClientSentimentMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = WeakRef.new dealing_platform
      end

      # Returns client sentiments for the specified markets.
      #
      # @param [Array<String>] market_ids The IDs of the markets to return client sentiments for.
      #
      # @return [Array<ClientSentiment>]
      def find(*market_ids)
        result = @dealing_platform.session.get "clientsentiment?marketIds=#{market_ids.join ','}"

        models = @dealing_platform.instantiate_models ClientSentiment, result.fetch(:client_sentiments)

        # Invalid market IDs are returned with both percentages set to zero
        models.each do |client_sentiment|
          if client_sentiment.long_position_percentage == 0.0 && client_sentiment.short_position_percentage == 0.0
            raise ArgumentError, "unknown market '#{client_sentiment.market_id}'"
          end
        end

        models
      end

      # Returns client sentiment for the specified market.
      #
      # @param [String] market_id The ID of the market to return client sentiment for.
      #
      # @return [ClientSentiment]
      def [](market_id)
        find(market_id).first
      end
    end
  end
end
