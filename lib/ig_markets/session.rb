module IGMarkets
  class Session
    attr_accessor :username, :password, :api_key, :platform

    attr_reader :cst, :x_security_token

    HOST_URLS = {
      demo:       'https://demo-api.ig.com/gateway/deal/',
      production: 'https://api.ig.com/gateway/deal/'
    }.freeze

    def sign_in
      validate_authentication

      payload = { identifier: username, password: password_encryptor.encrypt(password), encryptedPassword: true }

      sign_in_result = request method: :post, url: 'session', payload: payload, api_version: API_VERSION_1

      headers = sign_in_result.fetch(:response).headers
      @cst = headers.fetch :cst
      @x_security_token = headers.fetch :x_security_token

      sign_in_result.fetch :result
    end

    def sign_out
      delete 'session', API_VERSION_1 if alive?

      @cst = @x_security_token = nil
    end

    def alive?
      !cst.nil? && !x_security_token.nil?
    end

    def post(url, body, api_version)
      request(method: :post, url: url, payload: body, api_version: api_version).fetch :result
    end

    def get(url, api_version)
      request(method: :get, url: url, api_version: api_version).fetch :result
    end

    def delete(url, api_version)
      request(method: :delete, url: url, api_version: api_version).fetch :result
    end

    def inspect
      "#<#{self.class.name} #{cst}, #{x_security_token}>"
    end

    private

    def validate_authentication
      %i(username password api_key).each do |attribute|
        fail ArgumentError, "#{attribute} is not set" if send(attribute).to_s.empty?
      end

      fail ArgumentError, 'platform is invalid' unless HOST_URLS.key? platform
    end

    def password_encryptor
      result = get 'session/encryptionKey', API_VERSION_1

      PasswordEncryptor.new.tap do |e|
        e.encoded_public_key = result.fetch :encryption_key
        e.time_stamp = result.fetch :time_stamp
      end
    end

    def request(options)
      options[:url] = "#{HOST_URLS.fetch(platform)}#{URI.escape(options[:url])}"
      options[:headers] = request_headers(options)
      options[:payload] = options[:payload].to_json if options.key? :payload

      response = execute_request options
      result = process_response response

      { response: response, result: result }
    end

    def request_headers(options)
      headers = {}

      headers[:content_type] = headers[:accept] = 'application/json; charset=UTF-8'
      headers[:'X-IG-API-KEY'] = api_key
      headers[:version] = options.delete :api_version

      headers[:cst] = cst if cst
      headers[:x_security_token] = x_security_token if x_security_token

      headers
    end

    def execute_request(options)
      RestClient::Request.execute options
    rescue RestClient::Exception => e
      e.response
    end

    def process_response(response)
      result = begin
        JSON.parse response.body, symbolize_names: true
      rescue JSON::ParserError
        {}
      end

      result = ResponseParser.parse result

      fail RequestFailedError, response unless response.code == 200

      result
    end
  end
end
