module IGMarkets
  # This error class is raised by {Session} when a request to the IG Markets API fails.
  class RequestFailedError < StandardError
    # @return [String] The IG error returned by the failed request.
    attr_reader :error

    # @return [Fixnum] The HTTP status code that was returned.
    attr_reader :code

    # Initializes this request failure error from a `RestClient::Response` instance.
    #
    # @param [RestClient::Response] response
    def initialize(response)
      @error = JSON.parse(response.body)['errorCode']
      @code = response.code

      super "#<#{self.class.name} #{error}, #{code}>"
    end
  end
end
