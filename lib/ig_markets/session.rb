module IGMarkets
  class Session
    attr_accessor :print_requests

    attr_reader :host_url, :api_key, :cst, :x_security_token

    HOST_URLS = {
      demo:       'https://demo-api.ig.com/gateway/deal/',
      production: 'https://api.ig.com/gateway/deal/'
    }

    def login(username, password, api_key, platform)
      fail ArgumentError, 'platform must be :demo or :production' unless HOST_URLS.key?(platform)

      @host_url = HOST_URLS[platform]
      @api_key = api_key

      password = password_encryptor.encrypt(password)

      login_payload = { identifier: username, password: password, encryptedPassword: true }
      login_result = request method: :post, url: 'session', payload: login_payload, api_version: API_VERSION_1

      headers = login_result.fetch(:response).headers
      @cst = headers.fetch(:cst)
      @x_security_token = headers.fetch(:x_security_token)

      login_result.fetch(:result)
    end

    def logout
      delete('session', API_VERSION_1) if alive?

      @host_url = @api_key = @cst = @x_security_token = nil
    end

    def alive?
      !cst.nil? && !x_security_token.nil?
    end

    def post(url, body, api_version)
      request(method: :post, url: url, payload: body, api_version: api_version).fetch(:result)
    end

    def get(url, api_version)
      request(method: :get, url: url, api_version: api_version).fetch(:result)
    end

    def delete(url, api_version)
      request(method: :delete, url: url, api_version: api_version).fetch(:result)
    end

    def inspect
      "#<#{self.class.name} #{cst}, #{x_security_token}>"
    end

    private

    def password_encryptor
      result = get('session/encryptionKey', API_VERSION_1)

      encryptor = PasswordEncryptor.new
      encryptor.encoded_public_key = result.fetch(:encryption_key)
      encryptor.time_stamp = result.fetch(:time_stamp)

      encryptor
    end

    def request(options)
      options[:url] = "#{host_url}#{URI.escape(options[:url])}"
      options[:headers] = request_headers(options)
      options[:payload] = options[:payload].to_json if options[:payload]

      print_request options

      response = execute_request(options)
      result = process_response(response)

      { response: response, result: result }
    end

    def request_headers(options)
      headers = {}

      headers[:content_type] = headers[:accept] = 'application/json; charset=UTF-8'
      headers[:'X-IG-API-KEY'] = api_key
      headers[:version] = options.delete(:api_version)

      headers[:cst] = cst if cst
      headers[:x_security_token] = x_security_token if x_security_token

      headers
    end

    def execute_request(options)
      RestClient::Request.execute options
    rescue RestClient::Exception => e
      e.response
    end

    def print_request(options)
      puts "#{options[:method].upcase} #{options[:url]}" if print_requests
    end

    def process_response(response)
      result = begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      result = ResponseParser.parse result

      fail "Request failed, code: #{response.code}, error: #{result[:error_code] || result}" unless response.code == 200

      result
    end
  end
end
