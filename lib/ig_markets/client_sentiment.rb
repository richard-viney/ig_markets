module IGMarkets
  class ClientSentiment < Model
    attribute :long_position_percentage, Float
    attribute :market_id
    attribute :short_position_percentage, Float

    # Returns an array of client sentiments from markets that are related to this one.
    #
    # @return [Array<ClientSentiment>]
    def related
      @dealing_platform.gather "clientsentiment/related/#{market_id}", :client_sentiments, ClientSentiment
    end
  end
end
