describe IGMarkets::DealingPlatform::AccountMethods, :dealing_platform do
  let(:from) { Time.new 2014, 5, 20, 14, 30, 0 }
  let(:to) { Time.new 2014, 10, 27, 6, 45, 0 }

  before do
    allow(Time).to receive(:now).and_return(Time.new(2014, 11, 1))
  end

  it 'retrieves accounts' do
    accounts = [build(:account)]

    expect(session).to receive(:get).with('accounts').and_return(accounts: accounts)

    expect(dealing_platform.account.all).to eq(accounts)
  end

  it 'retrieves activities in a date range' do
    activities = [build(:activity)]

    url = 'history/activity?from=2014-05-20T14:30:00&to=2014-10-27T06:45:00&pageSize=500&detailed=TRUE'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities)

    expect(dealing_platform.account.activities(from: from, to: to)).to eq(activities)
  end

  it 'retrieves activities starting at a date' do
    activities = [build(:activity)]

    url = 'history/activity?from=2014-05-20T14:30:00&to=2014-11-01T00:00:00&pageSize=500&detailed=TRUE'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities)

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'retrieves more activities than the IG Markets API will return in one request' do
    activities = (0...1200).map { |index| build :activity, deal_id: index, date: Time.new(2014, 10, 27) }

    urls = [
      'history/activity?from=2014-05-20T14:30:00&to=2014-11-01T00:00:00&pageSize=500&detailed=TRUE',
      'history/activity?from=2014-05-20T14:30:00&to=2014-10-27T00:00:00&pageSize=500&detailed=TRUE',
      'history/activity?from=2014-05-20T14:30:00&to=2014-10-27T00:00:00&pageSize=500&detailed=TRUE'
    ]
    expect(session).to receive(:get).with(urls[0], IGMarkets::API_V3).and_return(activities: activities[0...500])
    expect(session).to receive(:get).with(urls[1], IGMarkets::API_V3).and_return(activities: activities[500...1000])
    expect(session).to receive(:get).with(urls[2], IGMarkets::API_V3).and_return(activities: activities[1000...1200])

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'retrieves transactions in a date range' do
    transactions = [build(:transaction)]

    url = 'history/transactions?from=2014-05-20T14:30:00&to=2014-10-27T06:45:00&type=ALL&pageSize=500'
    expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(from: from, to: to)).to eq(transactions)
  end

  it 'retrieves transactions starting at a date' do
    transactions = [build(:transaction)]

    url = 'history/transactions?type=DEPOSIT&from=2014-05-20T14:30:00&to=2014-11-01T00:00:00&pageSize=500'
    expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(type: :deposit, from: from)).to eq(transactions)
  end

  it 'accepts all valid transaction types' do
    transactions = [build(:transaction)]

    [:all, :all_deal, :withdrawal, :deposit].each do |type|
      url = "history/transactions?from=2014-05-20T14:30:00&to=2014-10-27T06:45:00&type=#{type.to_s.upcase}&pageSize=500"
      expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

      expect(dealing_platform.account.transactions(from: from, to: to, type: type)).to eq(transactions)
    end
  end

  it 'raises on an invalid transaction type' do
    expect { dealing_platform.account.transactions from: from, type: :invalid }
      .to raise_error(ArgumentError, 'invalid transaction type: invalid')
  end
end
