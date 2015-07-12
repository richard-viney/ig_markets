describe IGMarkets::Session do
  it 'logs in correctly' do
    session = IGMarkets::Session.new

    response = instance_double 'RestClient::Response'

    allow(response).to receive(:code).and_return(200)
    allow(response).to receive(:headers).and_return(cst: '1', x_security_token: '2')
    allow(response).to receive(:body).and_return(
      { encryptionKey: Base64.strict_encode64(OpenSSL::PKey::RSA.new(2048).to_pem), timeStamp: '1000' }.to_json,
      {}.to_json
    )

    expect(session).to receive(:execute_request).twice.and_return(response)

    expect(session.login('username', 'password', 'api_key', :demo)).to eq({})
  end

  context 'logged in session' do
    before(:each) do
      @session = IGMarkets::Session.new

      @session.instance_variable_set :@cst, 'cst'
      @session.instance_variable_set :@x_security_token, 'x_security_token'
      @session.instance_variable_set :@api_key, 'api_key'
    end

    it 'is alive' do
      expect(@session.alive?).to eq(true)
    end

    it 'passes correct headers with every request' do
      response = instance_double 'RestClient::Response'
      expect(response).to receive_messages(code: 200, body: { test: 1 }.to_json)

      request_body = { test: 12 }

      expected_request = {
        method: :post,
        url: 'the_url',
        payload: request_body.to_json,
        headers: {
          accept: 'application/json; charset=UTF-8',
          content_type: 'application/json; charset=UTF-8',
          version: 1,
          cst: 'cst',
          x_security_token: 'x_security_token'
        }
      }
      expected_request[:headers][:'X-IG-API-KEY'] = 'api_key'

      expect(@session).to receive(:execute_request).with(expected_request).and_return(response)
      expect(@session.post('the_url', request_body)).to eq(test: 1)
    end

    it 'can logout' do
      response = instance_double 'RestClient::Response'
      expect(response).to receive_messages(code: 200, body: {}.to_json)

      expect(@session).to receive(:execute_request).and_return(response)

      expect(@session.logout).to eq(nil)
      expect(@session.alive?).to eq(false)
    end

    it 'gathers elements in a collection' do
      response = instance_double 'RestClient::Response'
      expect(response).to receive_messages(code: 200, body: { theItems: %w(1 2) }.to_json)

      expect(@session).to receive(:execute_request).and_return(response)
      expect(@session.gather('url', :the_items) { |attributes| Integer(attributes) }).to eq([1, 2])
    end

    it 'fails when HTTP response is not 200' do
      response = instance_double 'RestClient::Response'
      expect(response).to receive_messages(code: 404, body: '')

      expect(@session).to receive(:execute_request).and_return(response)
      expect { @session.get('url') }.to raise_error(RuntimeError)
    end

    it 'is inspectable' do
      expect(@session.inspect).to eq('#<IGMarkets::Session cst, x_security_token>')
    end
  end
end
