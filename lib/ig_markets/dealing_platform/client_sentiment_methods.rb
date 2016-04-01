module IGMarkets
  class DealingPlatform
    # Helper class that provides methods for interacting with client sentiment.
    class ClientSentimentMethods
      # Initializes this helper class with the specified dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns the client sentiment for a market.
      #
      # @param [String] market_id The ID of the market to return client sentiment for.
      #
      # @return [ClientSentiment]
      def [](market_id)
        result = @dealing_platform.session.get "clientsentiment/#{market_id}", API_VERSION_1

        ClientSentiment.from(result).tap do |client_sentiment|
          client_sentiment.instance_variable_set :@dealing_platform, @dealing_platform
        end
      end
    end
  end
end
