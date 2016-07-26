module IGMarkets
  # This error class is raised by {Session} when a request to the IG Markets API fails.
  class RequestFailedError < StandardError
    # A description of the error that occurred when the request was attempted.
    #
    # @return [String]
    attr_reader :error

    # The HTTP code that was returned, or `nil` if unknown.
    #
    # @return [Fixnum]
    attr_reader :http_code

    # Initializes this request failure error with a message and an HTTP code.
    #
    # @param [String] error The error description.
    # @param [Integer] http_code The HTTP code for the request failure, if known.
    def initialize(error, http_code = nil)
      @error = error.to_s
      @http_code = http_code ? http_code.to_i : nil

      super "#<#{self.class.name} error: #{@error}#{http_code ? ", http_code: #{http_code}" : ''}>"
    end
  end
end
