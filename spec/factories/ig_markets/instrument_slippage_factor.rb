FactoryGirl.define do
  factory :instrument_slippage_factor, class: IGMarkets::Instrument::SlippageFactor do
    unit 'USD'
    value 1
  end
end
