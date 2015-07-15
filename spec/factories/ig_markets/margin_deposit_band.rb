FactoryGirl.define do
  factory :margin_deposit_band, class: IGMarkets::MarginDepositBand do
    currency 'USD'
    margin 0.01
    max 0.01
    min 0.01
  end
end
