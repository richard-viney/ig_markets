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
    metadata = { paging: { next: nil } }

    url = 'history/activity?from=2014-05-20T14%3A30%3A00&to=2014-10-27T06%3A45%3A00&pageSize=500&detailed=true'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities, metadata: metadata)

    expect(dealing_platform.account.activities(from: from, to: to)).to eq(activities)
  end

  it 'retrieves activities starting at a date' do
    activities = [build(:activity)]
    metadata = { paging: { next: nil } }

    url = 'history/activity?from=2014-05-20T14%3A30%3A00&to=2014-11-01T00%3A00%3A00&pageSize=500&detailed=true'
    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(activities: activities, metadata: metadata)

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'retrieves more activities than the IG Markets API will return in one request' do
    activities = (0...1200).map { |index| build :activity, deal_id: index, date: Time.new(2014, 10, 27) }

    urls = [
      'history/activity?from=2014-05-20T14%3A30%3A00&to=2014-11-01T00%3A00%3A00&pageSize=500&detailed=true',
      'history/activity?from=2014-05-20T14%3A30%3A00&to=2014-10-27T00%3A00%3A00&pageSize=500&detailed=true',
      'history/activity?from=2014-05-20T14%3A30%3A00&to=2014-10-27T00%3A00%3A00&pageSize=500&detailed=true'
    ]

    metadatas = [
      { paging: { next: urls[1] } },
      { paging: { next: urls[2] } },
      { paging: { next: nil } }
    ]

    expect(session)
      .to receive(:get)
      .with(urls[0], IGMarkets::API_V3)
      .and_return(activities: activities[0...500], metadata: metadatas[0])

    expect(session)
      .to receive(:get)
      .with(urls[1], IGMarkets::API_V3)
      .and_return(activities: activities[500...1000], metadata: metadatas[1])

    expect(session)
      .to receive(:get)
      .with(urls[2], IGMarkets::API_V3)
      .and_return(activities: activities[1000...1200], metadata: metadatas[2])

    expect(dealing_platform.account.activities(from: from)).to eq(activities)
  end

  it 'retrieves transactions in a date range' do
    transactions = [build(:transaction)]
    metadata = { page_data: { total_pages: 1 } }

    url = 'history/transactions?from=2014-05-20T14%3A30%3A00&to=2014-10-27T06%3A45%3A00&' \
          'type=ALL&pageSize=500&pageNumber=1'

    expect(session)
      .to receive(:get)
      .with(url, IGMarkets::API_V2)
      .and_return(transactions: transactions, metadata: metadata)

    expect(dealing_platform.account.transactions(from: from, to: to)).to eq(transactions)
  end

  it 'retrieves transactions starting at a date' do
    transactions = [build(:transaction)]
    metadata = { page_data: { total_pages: 1 } }

    url = 'history/transactions?type=DEPOSIT&from=2014-05-20T14%3A30%3A00&to=2014-11-01T00%3A00%3A00&' \
          'pageSize=500&pageNumber=1'

    expect(session)
      .to receive(:get)
      .with(url, IGMarkets::API_V2)
      .and_return(transactions: transactions, metadata: metadata)

    expect(dealing_platform.account.transactions(type: :deposit, from: from)).to eq(transactions)
  end

  it 'retrieves more transactions than the IG Markets API will return in one request' do
    transactions = Array.new(800) { build :transaction, date: Time.new(2014, 10, 27) }

    urls = [
      'history/transactions?type=ALL&from=2014-05-20T14%3A30%3A00&to=2014-11-01T00%3A00%3A00&pageSize=500&pageNumber=1',
      'history/transactions?type=ALL&from=2014-05-20T14%3A30%3A00&to=2014-11-01T00%3A00%3A00&pageSize=500&pageNumber=2'
    ]

    metadatas = [
      { page_data: { total_pages: 2 } },
      { page_data: { total_pages: 2 } }
    ]

    expect(session)
      .to receive(:get)
      .with(urls[0], IGMarkets::API_V2)
      .and_return(transactions: transactions[0...500], metadata: metadatas[0])

    expect(session)
      .to receive(:get)
      .with(urls[1], IGMarkets::API_V2)
      .and_return(transactions: transactions[500...800], metadata: metadatas[1])

    expect(dealing_platform.account.transactions(type: :all, from: from)).to eq(transactions)
  end

  it 'accepts all valid transaction types' do
    transactions = [build(:transaction)]
    metadata = { page_data: { total_pages: 1 } }

    %i[all all_deal withdrawal deposit].each do |type|
      url = 'history/transactions?from=2014-05-20T14%3A30%3A00&to=2014-10-27T06%3A45%3A00&' \
            "type=#{type.to_s.upcase}&pageSize=500&pageNumber=1"

      expect(session)
        .to receive(:get)
        .with(url, IGMarkets::API_V2)
        .and_return(transactions: transactions, metadata: metadata)

      expect(dealing_platform.account.transactions(from: from, to: to, type: type)).to eq(transactions)
    end
  end

  it 'raises on an invalid transaction type' do
    expect { dealing_platform.account.transactions from: from, type: :invalid }
      .to raise_error(ArgumentError, 'invalid transaction type: invalid')
  end
end
