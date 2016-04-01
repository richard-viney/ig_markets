module IGMarkets
  # This error class is raised by {Session} when a request to the IG Markets API fails.
  class RequestFailedError < StandardError
    # @return [Fixnum] The HTTP status code that was returned.
    attr_reader :code

    # @return [String] The body of the HTTP response from the failed request.
    attr_reader :body

    # Initializes this request failure error from a `RestClient::Response` instance.
    #
    # @param [RestClient::Response] response
    def initialize(response)
      @code = response.code
      @body = response.body

      super "#<#{self.class.name} code=#{code}, body=#{body}>"
    end
  end
end
