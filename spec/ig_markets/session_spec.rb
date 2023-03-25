describe IGMarkets::Session do
  let(:session) do
    described_class.new.tap do |session|
      session.username = 'username'
      session.password = 'password'
      session.api_key = 'api_key'
      session.platform = :live
    end
  end

  let(:key) { Base64.strict_encode64 OpenSSL::PKey::RSA.new(1024).to_pem }

  def build_response(options)
    instance_double Excon::Response, options
  end

  context 'with a non-signed in session' do
    it 'is not alive' do
      expect(session.alive?).to be(false)
    end

    it 'sign ins' do
      responses = [
        build_response(body: { encryptionKey: key, timeStamp: '1000' }.to_json),
        build_response(body: { clientId: 'id' }.to_json, headers: { 'CST' => '1', 'X-SECURITY-TOKEN' => '2' })
      ]

      expect(Excon).to receive(:get).and_return(responses[0])
      expect(Excon).to receive(:post).and_return(responses[1])

      expect(session.sign_in).to eq(client_id: 'id')

      expect(session.client_security_token).to eq('1')
      expect(session.x_security_token).to match('2')
      expect(session.alive?).to be(true)
    end
  end

  context 'with a signed in session' do
    before do
      session.instance_variable_set :@client_security_token, 'client_security_token'
      session.instance_variable_set :@x_security_token, 'x_security_token'
      session.instance_variable_set :@api_key, 'api_key'
      session.instance_variable_set :@platform, :live
    end

    it 'is alive' do
      expect(session.alive?).to be(true)
    end

    it 'performs a POST request' do
      response = build_response body: { ids: [1, 2] }.to_json
      expect(Excon).to receive(:post).with(full_url('url'), request_options(body: { id: 1 })).and_return(response)
      expect(session.post('url', id: 1)).to eq(ids: [1, 2])
    end

    it 'signs out' do
      response = build_response body: {}.to_json
      expect(Excon).to receive(:delete).with(full_url('session'), request_options).and_return(response)
      expect(session.sign_out).to be_nil
      expect(session.alive?).to be(false)
    end

    it 'retries after a pause if the API key allowance was exceeded' do
      responses = [
        build_response(body: { errorCode: 'error.public-api.exceeded-api-key-allowance' }.to_json),
        build_response(body: {}.to_json)
      ]

      expect(Excon).to receive(:post).with(full_url('test'), request_options(body: {})).and_return(responses[0])
      expect(session).to receive(:sleep).with(10)
      expect(Excon).to receive(:post).with(full_url('test'), request_options(body: {})).and_return(responses[1])

      expect(session.post('test', {})).to eq({})
    end

    it 'raises ConnectionError when Excon raises an error' do
      expect(Excon).to receive(:send).and_raise(Excon::Error, 'error')
      expect { session.get 'url' }.to raise_error(IGMarkets::Errors::ConnectionError, 'error')
    end

    it 'raises InvalidJSONError when the HTTP response is not valid JSON' do
      response = build_response body: 'not_valid_json'
      expect(Excon).to receive(:get).with(full_url('url'), request_options).and_return(response)
      expect { session.get 'url' }.to raise_error(IGMarkets::Errors::InvalidJSONError)
    end

    it 'attempts to sign in again if the client token is invalid' do
      responses = [
        build_response(body: { errorCode: 'error.security.client-token-invalid' }.to_json),
        build_response(body: { encryptionKey: key, timeStamp: '1000' }.to_json),
        build_response(body: {}.to_json, headers: { 'CST' => '3', 'X-SECURITY-TOKEN' => '4' }),
        build_response(body: { result: 'test' }.to_json)
      ]

      expect(Excon).to receive(:get).with(full_url('url'), request_options).and_return(responses[0])
      expect(Excon).to receive(:get)
        .with(full_url('session/encryptionKey'), request_options(client_security_token: false, x_security_token: false))
        .and_return(responses[1])
      expect(Excon).to receive(:post).and_return(responses[2])
      expect(Excon).to receive(:get)
        .with(full_url('url'), request_options(client_security_token: '3', x_security_token: '4'))
        .and_return(responses[3])

      expect(session.get('url')).to eq(result: 'test')

      expect(session.client_security_token).to eq('3')
      expect(session.x_security_token).to match('4')
      expect(session.alive?).to be(true)
    end

    it 'performs a PUT request' do
      response = build_response body: ''
      expect(Excon).to receive(:put).with(full_url('url'), request_options(body: { id: 1 })).and_return(response)
      expect(session.put('url', id: 1)).to eq({})
    end

    it 'performs a DELETE request with a body' do
      post_options = request_options body: { id: 1 }
      post_options[:headers]['_method'] = 'DELETE'

      response = build_response body: ''
      expect(Excon).to receive(:post).with(full_url('url'), post_options).and_return(response)
      expect(session.delete('url', id: 1)).to eq({})
    end

    it 'reports requests to debug output targets' do
      response = build_response body: { test: 2 }.to_json, headers: { test: '123' }

      log_sink = spy

      session.log_sinks = [log_sink]

      expect(log_sink).to receive(:write).with(<<~MSG
        POST https://api.ig.com/gateway/deal/test
          Headers:
            Accept: application/json; charset=UTF-8
            Content-Type: application/json; charset=UTF-8
            X-IG-API-KEY: api_key
            Version: 1
            CST: client_security_token
            X-SECURITY-TOKEN: x_security_token
          Body:
            {
              "test": 1
            }
      MSG
                                              )
      expect(log_sink).to receive(:write).with(<<-MSG
  Response:
    Headers:
      test: 123
    Body:
      {
        "test": 2
      }
      MSG
                                              )

      expect(Excon).to receive(:post).with(full_url('test'), request_options(body: { test: 1 })).and_return(response)

      session.post 'test', test: 1
    end

    def full_url(path)
      "https://api.ig.com/gateway/deal/#{path}"
    end

    def headers(options)
      hash = {}

      hash['Accept'] = hash['Content-Type'] = 'application/json; charset=UTF-8'
      hash['Version'] = 1
      hash['X-IG-API-KEY'] = 'api_key'

      client_security_token = options.fetch :client_security_token, 'client_security_token'
      hash['CST'] = client_security_token if client_security_token

      x_security_token = options.fetch :x_security_token, 'x_security_token'
      hash['X-SECURITY-TOKEN'] = x_security_token if x_security_token

      hash
    end

    def request_options(options = {})
      hash = {}
      hash[:headers] = headers options
      hash[:body] = options[:body] && options[:body].to_json
      hash
    end
  end
end
