describe IGMarkets::DealingPlatform do
  before :each do
    @session = IGMarkets::Session.new

    @platform = IGMarkets::DealingPlatform.new
    @platform.instance_variable_set :@session, @session
  end

  it 'can log in' do
    expect(@session).to receive(:login).with('username', 'password', 'api_key', :demo).and_return({})
    expect(@platform.login('username', 'password', 'api_key', :demo)).to eq({})
  end

  it 'can log out' do
    expect(@session).to receive(:logout).and_return(nil)
    expect(@platform.logout).to eq(nil)
  end

  it 'can retrieve accounts' do
    accounts = [build(:account), build(:account)]

    expect(@session).to receive(:gather).with('accounts', :accounts, IGMarkets::API_VERSION_1).and_return(accounts)
    expect(@platform.accounts).to eq(accounts)
  end
end
