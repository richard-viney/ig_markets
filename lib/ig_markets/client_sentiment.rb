module IGMarkets
  # Contains details on client sentiment for a single market. Returned by {DealingPlatform::ClientSentimentMethods#[]}
  # and {#related_sentiments}.
  class ClientSentiment < Model
    attribute :long_position_percentage, Float
    attribute :market_id
    attribute :short_position_percentage, Float

    # Returns client sentiments for markets that are related to this one.
    #
    # @return [Array<ClientSentiment>]
    def related_sentiments
      result = @dealing_platform.session.get("clientsentiment/related/#{market_id}").fetch :client_sentiments

      @dealing_platform.instantiate_models ClientSentiment, result
    end
  end
end
