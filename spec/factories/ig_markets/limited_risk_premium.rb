FactoryBot.define do
  factory :limited_risk_premium, class: 'IGMarkets::LimitedRiskPremium' do
    unit { 'POINTS' }
    value { 10 }
  end
end
