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

    expect(session).to receive(:get).with('history/activity/20-05-2014/27-10-2014').and_return(activities: activities)

    expect(platform.account.activities_in_date_range(Date.new(2014, 5, 20), Date.new(2014, 10, 27))).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:activity)]

    expect(session).to receive(:get).with('history/activity/604800000').and_return(activities: activities)

    expect(platform.account.recent_activities(7)).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions/ALL/20-05-2014/27-10-2014')
      .and_return(transactions: transactions)

    result = platform.account.transactions_in_date_range Date.new(2014, 5, 20), Date.new(2014, 10, 27), :all

    expect(result).to eq(transactions)
  end

  it 'can retrieve transactions in recent period' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions/DEPOSIT/604800000')
      .and_return(transactions: transactions)

    expect(platform.account.recent_transactions(7, :deposit)).to eq(transactions)
  end
end
