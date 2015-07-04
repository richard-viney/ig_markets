module IGMarkets
  class Session
    attr_accessor :print_requests

    HOST_URLS = {
      demo: 'https://demo-api.ig.com/gateway/deal',
      live: 'https://api.ig.com/gateway/deal'
    }

    def create(options = {})
      @host_url = HOST_URLS.fetch(options.fetch(:api))
      @api_key = options.fetch(:api_key)

      response, result = post '/session', identifier: options.fetch(:username), password: options.fetch(:password)

      @cst = response.headers.fetch(:cst)
      @x_security_token = response.headers.fetch(:x_security_token)

      result
    end

    def alive?
      !@cst.nil? && !@x_security_token.nil?
    end

    def post(url, body)
      request :post, "#{@host_url}#{url}", body.to_json
    end

    def get(url)
      request :get, "#{@host_url}#{url}"
    end

    def inspect
      "#<#{self.class.name} #{@cst}, #{@x_security_token}>"
    end

    private

    def request(method, *params)
      puts [method.upcase, params.join(', ')].join(' ') if print_requests

      response = RestClient.send(method, *(params << request_headers))

      fail "Request failed, code: #{response.code}" unless response.code == 200

      [response, JSON.parse(response.body, symbolize_names: true)]
    end

    def request_headers
      headers = {}

      headers[:content_type] = headers[:accept] = 'application/json; charset=UTF-8'
      headers['X-IG-API-KEY'] = @api_key

      headers[:cst] = @cst if @cst
      headers[:x_security_token] = @x_security_token if @x_security_token

      headers
    end
  end
end
