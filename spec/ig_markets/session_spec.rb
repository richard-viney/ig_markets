describe IGMarkets::Session do
  let(:response) { instance_double 'RestClient::Response' }
  let(:rest_client) { RestClient::Request }

  context 'a non-signed in session' do
    let(:session) do
      IGMarkets::Session.new.tap do |session|
        session.username = 'username'
        session.password = 'password'
        session.api_key = 'api_key'
        session.platform = :production
      end
    end

    it 'is not alive' do
      expect(session.alive?).to eq(false)
    end

    it 'can sign in' do
      expect(response).to receive(:code).exactly(4).times.and_return(200)
      expect(response).to receive(:headers).and_return(cst: '1', x_security_token: '2')
      expect(response).to receive(:body).twice.and_return(
        { encryptionKey: Base64.strict_encode64(OpenSSL::PKey::RSA.new(256).to_pem), timeStamp: '1000' }.to_json,
        {}.to_json
      )
      expect(rest_client).to receive(:execute).twice.and_return(response)

      expect(session.sign_in).to eq(nil)

      expect(session.cst).to eq('1')
      expect(session.x_security_token).to match('2')
      expect(session.alive?).to eq(true)
    end

    it 'fails to sign in when required attributes are missing' do
      %i(username password api_key platform).each do |attribute|
        session.send "#{attribute}=", nil
        expect { session.sign_in }.to raise_error(ArgumentError)
      end
    end
  end

  context 'a signed in session' do
    let(:session) do
      IGMarkets::Session.new.tap do |s|
        s.instance_variable_set :@cst, 'cst'
        s.instance_variable_set :@x_security_token, 'x_security_token'
        s.instance_variable_set :@api_key, 'api_key'
        s.instance_variable_set :@platform, :production
      end
    end

    it 'is alive' do
      expect(session.alive?).to eq(true)
    end

    it 'passes correct details for a post request' do
      expect(response).to receive_messages(code: 200, body: { ids: [1, 2] }.to_json)
      expect(rest_client).to receive(:execute).with(params(:post, 'url', id: 1)).and_return(response)
      expect(session.post('url', { id: 1 }, IGMarkets::API_V1)).to eq(ids: [1, 2])
    end

    it 'can sign out' do
      expect(response).to receive_messages(code: 200, body: {}.to_json)
      expect(rest_client).to receive(:execute).with(params(:delete, 'session')).and_return(response)
      expect(session.sign_out).to eq(nil)
      expect(session.alive?).to eq(false)
    end

    it 'fails when the HTTP response is not 200' do
      expect(response).to receive_messages(code: 404, body: { errorCode: '1' }.to_json)
      expect(rest_client).to receive(:execute).with(params(:get, 'url')).and_raise(RestClient::Exception, response)
      expect { session.get('url', IGMarkets::API_V1) }.to raise_error do |error|
        expect(error).to be_a(IGMarkets::RequestFailedError)
        expect(error.error).to eq('1')
        expect(error.http_code).to eq(404)
      end
    end

    it 'handles when the HTTP response is not JSON' do
      expect(response).to receive_messages(code: 404, body: 'not_valid_json')
      expect(rest_client).to receive(:execute).with(params(:get, 'url')).and_raise(RestClient::Exception, response)
      expect { session.get('url', IGMarkets::API_V1) }.to raise_error(IGMarkets::RequestFailedError)
    end

    it 'converts a SocketError into a RequestFailedError' do
      expect(rest_client).to receive(:execute).with(params(:get, 'url')).and_raise(SocketError)
      expect { session.get('url', IGMarkets::API_V1) }.to raise_error(IGMarkets::RequestFailedError)
    end

    it 'converts a RestClient::Exception that has no response into a RequestFailedError' do
      expect(rest_client).to receive(:execute).with(params(:get, 'url')).and_raise(RestClient::Exception)
      expect { session.get('url', IGMarkets::API_V1) }.to raise_error(IGMarkets::RequestFailedError)
    end

    it 'can process a PUT request' do
      expect(response).to receive_messages(code: 200, body: '')
      expect(rest_client).to receive(:execute).with(params(:put, 'url', id: 1)).and_return(response)
      expect(session.put('url', { id: 1 }, IGMarkets::API_V1)).to eq({})
    end

    it 'can process a DELETE request with a payload' do
      execute_params = params :post, 'url', id: 1
      execute_params[:headers]['_method'] = :delete

      expect(response).to receive_messages(code: 204, body: '')
      expect(rest_client).to receive(:execute).with(execute_params).and_return(response)
      expect(session.delete('url', { id: 1 }, IGMarkets::API_V1)).to eq({})
    end

    it 'inspects correctly' do
      expect(session.inspect).to eq('#<IGMarkets::Session cst, x_security_token>')
    end

    def headers
      hash = {}
      hash[:accept] = hash[:content_type] = 'application/json; charset=UTF-8'
      hash[:version] = 1
      hash[:cst] = 'cst'
      hash[:x_security_token] = 'x_security_token'
      hash[:'X-IG-API-KEY'] = 'api_key'
      hash
    end

    def params(method, url, payload = nil)
      hash = {}
      hash[:method] = method
      hash[:url] = "https://api.ig.com/gateway/deal/#{url}"
      hash[:headers] = headers
      hash[:payload] = payload && payload.to_json
      hash
    end
  end
end
