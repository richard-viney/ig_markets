describe IGMarkets::Activity do
  it 'accepts period in multiple formats' do
    expect(build(:activity, period: '-').period).to be nil
    expect(build(:activity, period: 'DFB').period).to be nil
    expect(build(:activity, period: 'JUN-22').period).to eq(Time.new(2022, 6, 1, 0, 0, 0))
    expect(build(:activity, period: '10-APR-03').period).to eq(Time.new(2003, 4, 10, 0, 0, 0))
    expect(build(:activity, period: '2016-04-04T03:40:07').period).to eq(Time.new(2016, 4, 4, 3, 40, 7))
  end
end
