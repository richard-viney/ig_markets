FactoryGirl.define do
  factory :instrument_slippage_factor, class: IGMarkets::InstrumentSlippageFactor do
    unit 'USD'
    value 1
  end
end
