module IGMarkets
  class DealingPlatform
    # Provides methods for working with client sentiment. Returned by {DealingPlatform#client_sentiment}.
    class ClientSentimentMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns the client sentiment for a market.
      #
      # @param [String] market_id The ID of the market to return client sentiment for.
      #
      # @return [ClientSentiment]
      def [](market_id)
        result = @dealing_platform.session.get "clientsentiment/#{market_id}", API_V1

        ClientSentiment.from(result).tap do |client_sentiment|
          client_sentiment.instance_variable_set :@dealing_platform, @dealing_platform
        end
      end
    end
  end
end
