module IGMarkets
  # Contains details on client sentiment for a single market. Returned by {DealingPlatform::ClientSentimentMethods#[]}
  # and {#related_sentiments}.
  class ClientSentiment < Model
    attribute :long_position_percentage, Float
    attribute :market_id
    attribute :short_position_percentage, Float

    # Returns an array of client sentiments from markets that are related to this one.
    #
    # @return [Array<ClientSentiment>]
    def related_sentiments
      @dealing_platform.gather "clientsentiment/related/#{market_id}", :client_sentiments, ClientSentiment
    end
  end
end
