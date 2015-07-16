describe IGMarkets::Session do
  def headers
    h = {}
    h[:accept] = h[:content_type] = 'application/json; charset=UTF-8'
    h[:version] = 1
    h[:cst] = 'cst'
    h[:x_security_token] = 'x_security_token'
    h[:'X-IG-API-KEY'] = 'api_key'
    h
  end

  def params(method, url, payload = nil)
    params = {}
    params[:method] = method
    params[:url] = "test://#{url}"
    params[:headers] = headers
    params[:payload] = payload.to_json if payload
    params
  end

  before(:each) do
    @response = instance_double 'RestClient::Response'
    @rest_client = RestClient::Request
  end

  it 'can log in' do
    session = IGMarkets::Session.new

    expect(@response).to receive(:code).twice.and_return(200)
    expect(@response).to receive(:headers).and_return(cst: '1', x_security_token: '2')
    expect(@response).to receive(:body).twice.and_return(
      { encryptionKey: Base64.strict_encode64(OpenSSL::PKey::RSA.new(256).to_pem), timeStamp: '1000' }.to_json,
      { id: 1 }.to_json
    )

    expect(@rest_client).to receive(:execute).twice.and_return(@response)
    expect(session.login('username', 'password', 'api_key', :demo)).to eq(id: 1)
    expect(session.host_url).to match(/^https:/)
    expect(session.api_key).to eq('api_key')
    expect(session.cst).to eq('1')
    expect(session.x_security_token).to match('2')
    expect(session.alive?).to eq(true)
  end

  context 'a logged in session' do
    before(:each) do
      @session = IGMarkets::Session.new.tap do |s|
        s.instance_variable_set :@cst, 'cst'
        s.instance_variable_set :@x_security_token, 'x_security_token'
        s.instance_variable_set :@api_key, 'api_key'
        s.instance_variable_set :@host_url, 'test://'
      end
    end

    it 'is alive' do
      expect(@session.alive?).to eq(true)
    end

    it 'passes correct details for a post request' do
      expect(@response).to receive_messages(code: 200, body: { ids: [1, 2] }.to_json)
      expect(@rest_client).to receive(:execute).with(params(:post, 'the_url', id: 1)).and_return(@response)
      expect(@session.post('the_url', { id: 1 }, IGMarkets::API_VERSION_1)).to eq(ids: [1, 2])
    end

    it 'can logout' do
      expect(@response).to receive_messages(code: 200, body: {}.to_json)
      expect(@rest_client).to receive(:execute).with(params(:delete, 'session')).and_return(@response)
      expect(@session.logout).to eq(nil)
      expect(@session.alive?).to eq(false)
    end

    it 'fails when the HTTP response is not 200' do
      expect(@response).to receive_messages(code: 404, body: '')
      expect(@rest_client).to receive(:execute).with(params(:get, 'url')).and_raise(RestClient::Exception, @response)
      expect { @session.get('url', IGMarkets::API_VERSION_1) }.to raise_error(RuntimeError)
    end

    it 'inspects correctly' do
      expect(@session.inspect).to eq('#<IGMarkets::Session cst, x_security_token>')
    end
  end
end
