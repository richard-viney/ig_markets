module IGMarkets
  # Manages a session with the IG Markets REST API, including signing in, signing out, and the sending of requests.
  # In order to sign in, {#username}, {#password}, {#api_key} and {#platform} must be set. {#platform} must be
  # either `:demo` or `:live` depending on which platform is being targeted.
  class Session
    # The username to use to authenticate this session.
    #
    # @return [String]
    attr_accessor :username

    # The password to use to authenticate this session.
    #
    # @return [String]
    attr_accessor :password

    # The API key to use to authenticate this session.
    #
    # @return [String]
    attr_accessor :api_key

    # The platform variant to log into for this session.
    #
    # @return [:demo, :live]
    attr_accessor :platform

    # The client session security access token for the currently logged in session, or `nil` if there is no active
    # session.
    #
    # @return [String]
    attr_reader :client_security_token

    # The account session security access token for the currently logged in session, or `nil` if there is no active
    # session.
    #
    # @return [String]
    attr_reader :x_security_token

    # Signs in to IG Markets using the values of {#username}, {#password}, {#api_key} and {#platform}. If an error
    # occurs then an {IGMarketsError} will be raised.
    #
    # @return [Hash] The data returned in the body of the sign in request.
    def sign_in
      @client_security_token = @x_security_token = nil

      body = { identifier: username, password: password_encryptor.encrypt(password), encryptedPassword: true }

      sign_in_result = request method: :post, url: 'session', body: body, api_version: API_V2

      headers = sign_in_result.fetch(:response).headers
      @client_security_token = headers.fetch 'CST'
      @x_security_token = headers.fetch 'X-SECURITY-TOKEN'

      sign_in_result.fetch :body
    end

    # Signs out of IG Markets, ending the current session (if any). If an error occurs then an {IGMarketsError} will be
    # raised.
    def sign_out
      delete 'session' if alive?

      @client_security_token = @x_security_token = nil
    end

    # Returns whether this session is currently alive and successfully signed in.
    #
    # @return [Boolean]
    def alive?
      !client_security_token.nil? && !x_security_token.nil?
    end

    # Sends a POST request to the IG Markets API. If an error occurs then an {IGMarketsError} will be raised.
    #
    # @param [String] url The URL to send the POST request to.
    # @param [Hash, nil] body The body to include with the POST request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def post(url, body, api_version = API_V1)
      request(method: :post, url: url, body: body, api_version: api_version).fetch :body
    end

    # Sends a GET request to the IG Markets API. If an error occurs then an {IGMarketsError} will be raised.
    #
    # @param [String] url The URL to send the GET request to.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def get(url, api_version = API_V1)
      request(method: :get, url: url, api_version: api_version).fetch :body
    end

    # Sends a PUT request to the IG Markets API. If an error occurs then an {IGMarketsError} will be raised.
    #
    # @param [String] url The URL to send the PUT request to.
    # @param [Hash, nil] body The body to include with the PUT request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def put(url, body = nil, api_version = API_V1)
      request(method: :put, url: url, body: body, api_version: api_version).fetch :body
    end

    # Sends a DELETE request to the IG Markets API. If an error occurs then an {IGMarketsError} will be raised.
    #
    # @param [String] url The URL to send the DELETE request to.
    # @param [Hash, nil] body The body to include with the DELETE request, this will be encoded as JSON.
    # @param [Fixnum] api_version The API version to target.
    #
    # @return [Hash] The response from the IG Markets API.
    def delete(url, body = nil, api_version = API_V1)
      request(method: :delete, url: url, body: body, api_version: api_version).fetch :body
    end

    private

    HOST_URLS = { demo: 'https://demo-api.ig.com/gateway/deal/', live: 'https://api.ig.com/gateway/deal/' }.freeze

    def password_encryptor
      result = get 'session/encryptionKey'

      PasswordEncryptor.new result.fetch(:encryption_key), result.fetch(:time_stamp)
    end

    def request(options)
      options[:url] = "#{HOST_URLS.fetch(platform)}#{URI.escape(options[:url])}"
      options[:headers] = request_headers(options)

      # The IG Markets API requires that DELETE requests with a body are sent as POST requests with a special header
      if options[:method] == :delete && options[:body]
        options[:headers]['_method'] = 'DELETE'
        options[:method] = :post
      end

      options[:body] = options[:body] && options[:body].to_json

      execute_request options
    end

    def request_headers(options)
      headers = {}

      headers['Content-Type'] = headers['Accept'] = 'application/json; charset=UTF-8'
      headers['X-IG-API-KEY'] = api_key
      headers['Version'] = options.delete :api_version

      headers['CST'] = client_security_token if client_security_token
      headers['X-SECURITY-TOKEN'] = x_security_token if x_security_token

      headers
    end

    def execute_request(options)
      RequestPrinter.print_options options

      response = Excon.send options[:method], options[:url], headers: options[:headers], body: options[:body]

      RequestPrinter.print_response_body response.body

      process_response response, options
    rescue Excon::Error => error
      raise Errors::ConnectionError, error.message
    end

    def process_response(response, options)
      body = parse_body response

      if body.key? :error_code
        error = IGMarketsError.build body[:error_code]

        raise error unless should_retry_request? error, options

        execute_request options.merge(retry: true)
      else
        { response: response, body: body }
      end
    end

    def parse_body(response)
      return {} if response.body == ''

      ResponseParser.parse JSON.parse(response.body)
    rescue JSON::ParserError
      raise Errors::InvalidJSONError, response.body
    end

    def should_retry_request?(error, options)
      if error.is_a?(Errors::ClientTokenInvalidError) && !options[:retry]
        sign_in
        true
      elsif error.is_a?(Errors::ExceededAPIKeyAllowanceError) || error.is_a?(Errors::ExceededAccountAllowanceError)
        sleep 5
        true
      end
    end
  end
end
