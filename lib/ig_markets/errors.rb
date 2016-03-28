module IGMarkets
  # This error class is raised by {Session} when a request to the IG Markets API fails.
  class RequestFailedError < StandardError
    attr_reader :code, :body

    def initialize(response)
      @code = response.code
      @body = response.body

      super "#<#{self.class.name} code=#{code}, body=#{body}>"
    end
  end
end
