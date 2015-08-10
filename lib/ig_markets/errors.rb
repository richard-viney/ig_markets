module IGMarkets
  class RequestFailedError < StandardError
    attr_reader :code, :body

    def initialize(response)
      @code = response.code
      @body = response.body

      super "#<#{self.class.name} code=#{code}, body=#{body}>"
    end
  end
end
