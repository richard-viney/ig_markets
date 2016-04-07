module IGMarkets
  # Manages a session with the IG Markets REST API, including signing in, signing out, and the sending of requests.
  # In order to sign in, {#username}, {#password}, {#api_key} and {#platform} must be set. {#platform} must be
  # either `:demo` or `:production` depending on which platform is being targeted.
  class Session
    # @return [String] The username to use to authenticate this session.
    attr_accessor :username

    # @return [String] The password to use to authenticate this session.
    attr_accessor :password

    # @return [String] The API key to use to authenticate this session.
    attr_accessor :api_key

    # @return [:demo, :production] The platform variant to log into for this session.
    attr_accessor :platform

    # @return [String] The CST for the currently logged in session, or nil if there is no active session.
    attr_reader :cst

    # @return [String] The security token for the currently logged in session, or nil if there is no active session.
    attr_reader :x_security_token

    # Signs in to IG Markets using the values of {#username}, {#password}, {#api_key} and {#platform}. If an error
    # occurs then {RequestFailedError} will be raised.
    def sign_in
      validate_authentication

      payload = { identifier: username, password: password_encryptor.encrypt(password), encryptedPassword: true }

      sign_in_result = request method: :post, url: 'session', payload: payload, api_version: API_V1

      headers = sign_in_result.fetch(:response).headers
      @cst = headers.fetch :cst
      @x_security_token = headers.fetch :x_security_token

      nil
    end

    # Signs out of IG Markets, ending the current session (if any). If an error occurs then {RequestFailedError} will be
    # raised.
    def sign_out
      delete 'session', nil, API_V1 if alive?

      @cst = @x_security_token = nil
    end

    # Returns whether this session is currently alive and successfully signed in.
    #
    # @return [Boolean]
    def alive?
      !cst.nil? && !x_security_token.nil?
    end

    # Sends a POST request to the IG Markets API. If an error occurs then {RequestFailedError} will be raised.
    #
    # @param [String] url The URL to send the POST request to.
    # @param [nil, String, Hash] payload The payload to include with the POST request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def post(url, payload, api_version)
      request(method: :post, url: url, payload: payload, api_version: api_version).fetch :result
    end

    # Sends a GET request to the IG Markets API. If an error occurs then {RequestFailedError} will be raised.
    #
    # @param [String] url The URL to send the GET request to.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def get(url, api_version)
      request(method: :get, url: url, api_version: api_version).fetch :result
    end

    # Sends a PUT request to the IG Markets API. If an error occurs then {RequestFailedError} will be raised.
    #
    # @param [String] url The URL to send the PUT request to.
    # @param [nil, String, Hash] payload The payload to include with the PUT request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def put(url, payload, api_version)
      request(method: :put, url: url, payload: payload, api_version: api_version).fetch :result
    end

    # Sends a DELETE request to the IG Markets API. If an error occurs then {RequestFailedError} will be raised.
    #
    # @param [String] url The URL to send the DELETE request to.
    # @param [nil, String, Hash] payload The payload to include with the DELETE request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def delete(url, payload, api_version)
      request(method: :delete, url: url, payload: payload, api_version: api_version).fetch :result
    end

    # Returns a human-readable string containing this session's details.
    #
    # @return [String]
    def inspect
      "#<#{self.class.name} #{cst}, #{x_security_token}>"
    end

    private

    HOST_URLS = {
      demo: 'https://demo-api.ig.com/gateway/deal/',
      production: 'https://api.ig.com/gateway/deal/'
    }.freeze

    def validate_authentication
      %i(username password api_key).each do |attribute|
        raise ArgumentError, "#{attribute} is not set" if send(attribute).to_s.empty?
      end

      raise ArgumentError, 'platform is invalid' unless HOST_URLS.key? platform
    end

    def password_encryptor
      result = get 'session/encryptionKey', API_V1

      PasswordEncryptor.new.tap do |encryptor|
        encryptor.encoded_public_key = result.fetch :encryption_key
        encryptor.time_stamp = result.fetch :time_stamp
      end
    end

    def request(options)
      options[:url] = "#{HOST_URLS.fetch(platform)}#{URI.escape(options[:url])}"
      options[:headers] = request_headers(options)
      options[:payload] = options[:payload] && options[:payload].to_json

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

    def use_post_for_delete_with_payload(options)
      if options[:method] == :delete && options[:payload]
        options[:headers]['_method'] = :delete
        options[:method] = :post
      end
    end

    def execute_request(options)
      use_post_for_delete_with_payload options

      RestClient::Request.execute options
    rescue RestClient::Exception => exception
      return exception.response if exception.response

      raise RequestFailedError, exception.message
    rescue SocketError => socket_error
      raise RequestFailedError, socket_error
    end

    def process_response(response)
      result = begin
        ResponseParser.parse JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      unless response.code >= 200 && response.code < 300
        raise RequestFailedError.new(result[:error_code], response.code)
      end

      result
    end
  end
end
