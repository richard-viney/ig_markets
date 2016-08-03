describe IGMarkets::Transaction do
  it 'accepts period in multiple formats' do
    expect(build(:transaction, period: '-').period).to be nil
    expect(build(:transaction, period: 'DFB').period).to be nil
    expect(build(:transaction, period: 'JUN-22').period).to eq(Time.new(2022, 6, 1, 0, 0, 0))
    expect(build(:transaction, period: '10-APR-03').period).to eq(Time.new(2003, 4, 10, 0, 0, 0))
    expect(build(:transaction, period: '2016-04-04T03:40:07').period).to eq(Time.new(2016, 4, 4, 3, 40, 7))
  end

  it 'identifies interest payments' do
    {
      { transaction_type: :with, instrument_name: 'interest' } => true,
      { transaction_type: :depo, instrument_name: ',interest' } => true,
      { transaction_type: :with, instrument_name: 'interest,' } => true,
      { transaction_type: :depo, instrument_name: ',interest,' } => true,
      { transaction_type: :with, instrument_name: 'pinterest' } => false,
      { transaction_type: :depo, instrument_name: 'interests' } => false
    }.each do |attributes, result|
      expect(build(:transaction, attributes).interest?).to eq(result)
    end
  end

  it 'reports profit/loss amounts' do
    expect(build(:transaction, currency: '$', profit_and_loss: '$1,000.00').profit_and_loss_amount).to eq(1000)
    expect(build(:transaction, currency: 'AU', profit_and_loss: 'AU-5.50').profit_and_loss_amount).to eq(-5.5)

    expect { build(:transaction, currency: 'USD', profit_and_loss: 'EUR-5.0').profit_and_loss_amount }
      .to raise_error(StandardError)
  end
end
