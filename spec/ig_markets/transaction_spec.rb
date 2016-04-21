describe IGMarkets::Transaction do
  it 'correctly identifies interest payments' do
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

  it 'reports correct profit/loss amounts' do
    expect(build(:transaction, currency: '$', profit_and_loss: '$1,000.00').profit_and_loss_amount).to eq(1000)
    expect(build(:transaction, currency: 'AU', profit_and_loss: 'AU-5.50').profit_and_loss_amount).to eq(-5.5)

    expect { build(:transaction, currency: 'USD', profit_and_loss: 'EUR-5.0').profit_and_loss_amount }
      .to raise_error(StandardError)
  end
end
