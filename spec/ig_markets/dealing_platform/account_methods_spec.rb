describe IGMarkets::DealingPlatform::AccountMethods do
  include_context 'dealing_platform'

  let(:from) { Date.new 2014, 5, 20 }
  let(:to) { Date.new 2014, 10, 27 }

  it 'can retrieve accounts' do
    accounts = [build(:account)]

    expect(session).to receive(:get).with('accounts').and_return(accounts: accounts)

    expect(dealing_platform.account.all).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:activity)]

    expect(session).to receive(:get)
      .with('history/activity?from=2014-05-20&to=2014-10-27&pageSize=0', IGMarkets::API_V2)
      .and_return(activities: activities)

    expect(dealing_platform.account.activities(from: from, to: to)).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:activity)]

    expect(session).to receive(:get)
      .with('history/activity?maxSpanSeconds=604800&pageSize=0', IGMarkets::API_V2)
      .and_return(activities: activities)

    expect(dealing_platform.account.activities(days: 7)).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions?from=2014-05-20&to=2014-10-27&type=ALL&pageSize=0', IGMarkets::API_V2)
      .and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(from: from, to: to)).to eq(transactions)
  end

  it 'can retrieve transactions in recent period' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions?type=DEPOSIT&maxSpanSeconds=604800&pageSize=0', IGMarkets::API_V2)
      .and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(type: :deposit, days: 7)).to eq(transactions)
  end
end
