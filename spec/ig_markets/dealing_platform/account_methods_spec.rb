describe IGMarkets::DealingPlatform::AccountMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve accounts' do
    accounts = [build(:account)]

    expect(session).to receive(:get).with('accounts').and_return(accounts: accounts)

    expect(platform.account.all).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:activity)]

    expect(session).to receive(:get)
      .with('history/activity?from=2014-05-20&to=2014-10-27', IGMarkets::API_V2)
      .and_return(activities: activities)

    expect(platform.account.activities(from: Date.new(2014, 5, 20), to: Date.new(2014, 10, 27))).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:activity)]

    expect(session).to receive(:get)
      .with('history/activity?maxSpanSeconds=604800', IGMarkets::API_V2)
      .and_return(activities: activities)

    expect(platform.account.activities(days: 7)).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions?from=2014-05-20&to=2014-10-27&type=ALL', IGMarkets::API_V2)
      .and_return(transactions: transactions)

    result = platform.account.transactions from: Date.new(2014, 5, 20), to: Date.new(2014, 10, 27)

    expect(result).to eq(transactions)
  end

  it 'can retrieve transactions in recent period' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions?type=DEPOSIT&maxSpanSeconds=604800', IGMarkets::API_V2)
      .and_return(transactions: transactions)

    expect(platform.account.transactions(type: :deposit, days: 7)).to eq(transactions)
  end
end
