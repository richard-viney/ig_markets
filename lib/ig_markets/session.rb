module IGMarkets
  class Session
    attr_accessor :print_requests

    HOST_URLS = {
      demo:       'https://demo-api.ig.com/gateway/deal',
      production: 'https://api.ig.com/gateway/deal'
    }

    API_VERSION_1 = 1
    API_VERSION_2 = 2

    def login(username, password, api_key, platform)
      fail ArgumentError, 'platform must be :demo or :production' unless HOST_URLS.key?(platform)

      @host_url = HOST_URLS[platform]
      @api_key = api_key

      password = encrypt_password(password)

      response, result = post '/session', identifier: username, password: password, encryptedPassword: true

      @cst = response.headers.fetch(:cst)
      @x_security_token = response.headers.fetch(:x_security_token)

      result
    end

    def logout
      delete '/session' if alive?

      @host_url = @api_key = @cst = @x_security_token = nil
    end

    def alive?
      !@cst.nil? && !@x_security_token.nil?
    end

    def post(url, body, api_version = API_VERSION_1)
      request method: :post, url: url, payload: body.to_json, api_version: api_version
    end

    def get(url, api_version = API_VERSION_1)
      request method: :get, url: url, api_version: api_version
    end

    def delete(url, api_version = API_VERSION_1)
      request method: :delete, url: url, api_version: api_version
    end

    def gather(url, collection, api_version = API_VERSION_1)
      _, result = get url, api_version
      result.fetch(collection).map { |attributes| yield attributes }
    end

    def inspect
      "#<#{self.class.name} #{@cst}, #{@x_security_token}>"
    end

    private

    def encrypt_password(password)
      _, result = get '/session/encryptionKey'

      PasswordEncryptor.new(result.fetch(:encryption_key), result.fetch(:time_stamp)).encrypt(password)
    end

    def request(options)
      options[:url] = "#{@host_url}#{URI.escape(options[:url])}"
      options[:headers] = request_headers(options)

      print_request options

      response = execute_request(options)
      result = process_response(response)

      fail "Request failed, code: #{response.code}, error: #{result[:error_code] || result}" unless response.code == 200

      [response, result]
    end

    def print_request(options)
      puts "#{options[:method].upcase} #{options[:url]}" if print_requests
    end

    def request_headers(options)
      headers = {}

      headers[:content_type] = headers[:accept] = 'application/json; charset=UTF-8'
      headers['X-IG-API-KEY'] = @api_key
      headers[:version] = options.delete(:api_version)

      headers[:cst] = @cst if @cst
      headers[:x_security_token] = @x_security_token if @x_security_token

      headers
    end

    def execute_request(options)
      RestClient::Request.execute options
    rescue RestClient::Exception => e
      e.response
    end

    def process_response(response)
      result = begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      snake_case_hash_keys(result)
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
