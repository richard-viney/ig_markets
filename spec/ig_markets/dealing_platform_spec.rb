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

    expect(@session).to receive(:get)
      .with('accounts', IGMarkets::API_VERSION_1)
      .and_return(accounts: accounts.map(&:attributes))

    expect(@platform.accounts).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:account_activity)]

    expect(@session).to receive(:get)
      .with('history/activity/20-05-2014/27-10-2014', IGMarkets::API_VERSION_1)
      .and_return(activities: activities.map(&:attributes))

    expect(@platform.activities_in_date_range Date.new(2014, 5, 20), Date.new(2014, 10, 27)).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:account_activity)]

    expect(@session).to receive(:get)
      .with('history/activity/1000', IGMarkets::API_VERSION_1)
      .and_return(activities: activities.map(&:attributes))

    expect(@platform.activities_in_recent_period 1000).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    expect(@session).to receive(:get)
      .with('history/transactions/ALL/20-05-2014/27-10-2014', IGMarkets::API_VERSION_1)
      .and_return(transactions: transactions.map(&:attributes))

    expect(@platform.transactions_in_date_range Date.new(2014, 5, 20), Date.new(2014, 10, 27), :all).to eq(transactions)
  end

  it 'can retrieve transactions in recent period' do
    transactions = [build(:transaction)]

    expect(@session).to receive(:get)
      .with('history/transactions/DEPOSIT/1000', IGMarkets::API_VERSION_1)
      .and_return(transactions: transactions.map(&:attributes))

    expect(@platform.transactions_in_recent_period 1000, :deposit).to eq(transactions)
  end

  it 'can retrieve all current positions' do
    positions = [build(:position)]

    expect(@session).to receive(:get)
      .with('positions', IGMarkets::API_VERSION_2)
      .and_return(positions: positions.map(&:attributes).map { |a| { market: a.delete('market'), position: a } })

    expect(@platform.positions).to eq(positions)
  end

  it 'can retrieve a single position' do
    position = build(:position)

    expect(@session).to receive(:get)
      .with("positions/#{position.deal_id}", IGMarkets::API_VERSION_2)
      .and_return(position: position.attributes, market: position.market)

    expect(@platform.position(position.deal_id)).to eq(position)
  end
end
