module IGMarkets
  # This error class is raised by {Session} when a request to the IG Markets API fails.
  class RequestFailedError < StandardError
    # @return [String] A description of the error that occurred when the request was attempted, or `nil` if unknown.
    attr_reader :error

    # @return [Fixnum] The HTTP code that was returned, or `nil` if unknown.
    attr_reader :http_code

    # Initializes this request failure error from a `RestClient::Response` or a `SocketError`.
    #
    # @param [RestClient::Response, SocketError] response
    def initialize(response)
      if response.is_a? SocketError
        @error = response.to_s

        super "#<#{self.class.name} #{error}>"
      else
        parse_rest_client_response response

        super "#<#{self.class.name} http_code: #{http_code}, error: #{error}>"
      end
    end

    private

    def parse_rest_client_response(response)
      @error = begin
        JSON.parse(response.body)['errorCode']
      rescue JSON::ParserError
        nil
      end

      @http_code = response.code
    end
  end
end
