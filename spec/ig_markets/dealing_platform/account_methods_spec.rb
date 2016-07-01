describe IGMarkets::DealingPlatform::AccountMethods, :dealing_platform do
  let(:from) { Date.new 2014, 5, 20 }
  let(:to) { Date.new 2014, 10, 27 }

  before do
    allow(Date).to receive(:today).and_return(Date.new(2014, 11, 1))
  end

  it 'can retrieve accounts' do
    accounts = [build(:account)]

    expect(session).to receive(:get).with('accounts').and_return(accounts: accounts)

    expect(dealing_platform.account.all).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:activity)]

    url = 'history/activity?from=2014-05-20&to=2014-10-27&pageSize=500&detailed=TRUE'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities)

    expect(dealing_platform.account.activities(from: from, to: to)).to eq(activities)
  end

  it 'can retrieve activities starting at a date' do
    activities = [build(:activity)]

    url = 'history/activity?from=2014-05-20&to=2014-11-02&pageSize=500&detailed=TRUE'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities)

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'can retrieve more activities than the IG Markets API will return in one request' do
    activities = (0...1200).map { |index| build :activity, deal_id: index, date: Time.new(2014, 10, 27) }

    urls = [
      'history/activity?from=2014-05-20&to=2014-11-02&pageSize=500&detailed=TRUE',
      'history/activity?from=2014-05-20&to=2014-10-28&pageSize=500&detailed=TRUE',
      'history/activity?from=2014-05-20&to=2014-10-28&pageSize=500&detailed=TRUE'
    ]
    expect(session).to receive(:get).with(urls[0], IGMarkets::API_V3).and_return(activities: activities[0...500])
    expect(session).to receive(:get).with(urls[1], IGMarkets::API_V3).and_return(activities: activities[500...1000])
    expect(session).to receive(:get).with(urls[2], IGMarkets::API_V3).and_return(activities: activities[1000...1200])

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    url = 'history/transactions?from=2014-05-20&to=2014-10-27&type=ALL&pageSize=500'
    expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(from: from, to: to)).to eq(transactions)
  end

  it 'can retrieve transactions starting at a date' do
    transactions = [build(:transaction)]

    url = 'history/transactions?type=DEPOSIT&from=2014-05-20&to=2014-11-02&pageSize=500'
    expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

    expect(dealing_platform.account.transactions(type: :deposit, from: from)).to eq(transactions)
  end

  it 'accepts all valid transaction types' do
    transactions = [build(:transaction)]

    [:all, :all_deal, :withdrawal, :deposit].each do |type|
      url = "history/transactions?from=2014-05-20&to=2014-10-27&type=#{type.to_s.upcase}&pageSize=500"
      expect(session).to receive(:get).with(url, IGMarkets::API_V2).and_return(transactions: transactions)

      expect(dealing_platform.account.transactions(from: from, to: to, type: type)).to eq(transactions)
    end
  end

  it 'raises an error on an invalid transaction type' do
    expect { dealing_platform.account.transactions from: from, type: :invalid }.to raise_error(ArgumentError)
  end
end
