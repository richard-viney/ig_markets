describe IGMarkets::DealingPlatform do
  before(:each) do
    @session = IGMarkets::Session.new

    @platform = IGMarkets::DealingPlatform.new
    @platform.instance_variable_set :@session, @session

    @response = instance_double 'RestClient::Response'
    allow(@response).to receive(:code).and_return(200)

    expect(@session).to receive(:execute_request).and_return(@response)
  end

  it 'can retrieve accounts' do
    response_body = { accounts: [build(:account_response), build(:account_response)] }
    accounts = response_body[:accounts].map { |a| IGMarkets::ResponseParser.parse(a) }

    expect(@response).to receive(:body).and_return(response_body.to_json)
    expect(@platform.accounts.map(&:deep_attributes_hash)).to eq(accounts)
  end
end
