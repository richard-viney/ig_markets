describe IGMarkets::DealingPlatform do
  it 'correctly identifies interest payments' do
    {
      { transaction_type: :with, instrument_name: 'interest' } => true,
      { transaction_type: :depo, instrument_name: ',interest' } => true,
      { transaction_type: :with, instrument_name: 'interest,' } => true,
      { transaction_type: :depo, instrument_name: ',interest,' } => true,
      { transaction_type: :with, instrument_name: 'pinterest' } => false,
      { transaction_type: :depo, instrument_name: 'interests' } => false
    }.each do |attributes, result|
      expect(build(:account_transaction, attributes).interest?).to eq(result)
    end
  end

  it 'reports correct profit/loss amounts' do
    expect(build(:account_transaction, currency: '$', profit_and_loss: '$1,000.00').profit_and_loss_amount).to eq(1000)
    expect(build(:account_transaction, currency: 'AU', profit_and_loss: 'AU-5.50').profit_and_loss_amount).to eq(-5.5)

    expect { build(:account_transaction, currency: 'USD', profit_and_loss: 'EUR-5.0').profit_and_loss_amount }
      .to raise_error(StandardError)
  end

  it 'formats transaction types' do
    expect(build(:account_transaction, transaction_type: :deal).formatted_transaction_type).to eq('Deal')
    expect(build(:account_transaction, transaction_type: :depo).formatted_transaction_type).to eq('Deposit')
    expect(build(:account_transaction, transaction_type: :dividend).formatted_transaction_type).to eq('Dividend')
    expect(build(:account_transaction, transaction_type: :exchange).formatted_transaction_type).to eq('Exchange')
    expect(build(:account_transaction, transaction_type: :with).formatted_transaction_type).to eq('Withdrawal')
  end
end
