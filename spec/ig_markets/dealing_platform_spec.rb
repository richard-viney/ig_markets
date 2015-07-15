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
    accounts = [build(:account)]

    expect(@session).to receive(:gather)
      .with('accounts', :accounts, IGMarkets::API_VERSION_1)
      .and_return(accounts)

    expect(@platform.accounts).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:account_activity)]

    expect(@session).to receive(:gather)
      .with('history/activity/20-05-2014/27-10-2014', :activities, IGMarkets::API_VERSION_1)
      .and_return(activities)

    expect(@platform.activities_in_date_range Date.new(2014, 05, 20), Date.new(2014, 10, 27)).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:account_activity)]

    expect(@session).to receive(:gather)
      .with('history/activity/1000', :activities, IGMarkets::API_VERSION_1)
      .and_return(activities)

    expect(@platform.activities_in_recent_period 1000).to eq(activities)
  end
end
