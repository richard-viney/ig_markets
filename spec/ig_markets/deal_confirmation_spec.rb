describe IGMarkets::DealConfirmation do
  it 'accepts different expiry formats' do
    expect(build(:deal_confirmation, expiry: '-').expiry).to eq(nil)
    expect(build(:deal_confirmation, expiry: 'DFB').expiry).to eq(nil)
    expect(build(:deal_confirmation, expiry: 'SEP-16').expiry).to eq(Date.new(2016, 9, 1))
    expect(build(:deal_confirmation, expiry: '08-DEC-16').expiry).to eq(Date.new(2016, 12, 8))
  end
end
