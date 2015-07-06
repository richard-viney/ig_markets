module IGMarkets
  class Session
    attr_accessor :print_requests

    HOST_URLS = {
      demo:       'https://demo-api.ig.com/gateway/deal',
      production: 'https://api.ig.com/gateway/deal'
    }

    def create(username, password, api_key, platform)
      fail ArgumentError, 'platform must be :demo or :production' unless HOST_URLS.key?(platform)

      @host_url = HOST_URLS[platform]
      @api_key = api_key

      response, result = post '/session', identifier: username, password: password

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

    def gather(collection, url)
      _, result = get(url)

      result.fetch(collection).map do |attributes|
        yield attributes
      end
    end

    def inspect
      "#<#{self.class.name} #{@cst}, #{@x_security_token}>"
    end

    private

    def request(method, *params)
      print_request method, *params

      response = begin
        RestClient.send method, *(params << request_headers)
      rescue RestClient::Exception => e
        e.response
      end

      result = parse_response(response)

      fail "Request failed, code: #{response.code}, error: #{result[:error_code] || result}" unless response.code == 200

      [response, result]
    end

    def print_request(method, *params)
      puts [method.upcase, params.join(', ')].join(' ') if print_requests
    end

    def parse_response(response)
      result = begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      snake_case_hash_keys(result)
    end

    def request_headers
      headers = {}

      headers[:content_type] = headers[:accept] = 'application/json; charset=UTF-8'
      headers['X-IG-API-KEY'] = @api_key

      headers[:cst] = @cst if @cst
      headers[:x_security_token] = @x_security_token if @x_security_token

      headers
    end

    def snake_case_hash_keys(object)
      if object.is_a? Hash
        object.each_with_object({}) do |(k, v), new_hash|
          new_hash[k.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym] = snake_case_hash_keys(v)
        end
      elsif object.is_a? Enumerable
        object.map { |a| snake_case_hash_keys(a) }
      else
        object
      end
    end
  end
end
