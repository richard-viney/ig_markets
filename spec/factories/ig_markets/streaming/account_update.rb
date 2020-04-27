FactoryBot.define do
  factory :streaming_account_update, class: 'IGMarkets::Streaming::AccountUpdate' do
    account_id { 'ACCOUNT' }
    available_cash { 8_000.0 }
    available_to_deal { 8_000.0 }
    deposit { 10_000.0 }
    equity { 10_000.0 }
    equity_used { 1_000.0 }
    funds { 10_500.0 }
    margin { 100.0 }
    margin_lr { 100.0 }
    margin_nlr { 0.0 }
    pnl { 500.0 }
    pnl_lr { 500.0 }
    pnl_nlr { 0.0 }
  end
end
