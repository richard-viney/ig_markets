module IGMarkets
  module Streaming
    # Contains details on an account update received via the streaming API. Used by {Streaming::Subscription#on_data}.
    class AccountUpdate < Model
      attribute :account_id
      attribute :available_cash, Float
      attribute :available_to_deal, Float
      attribute :deposit, Float
      attribute :equity, Float
      attribute :equity_used, Float
      attribute :funds, Float
      attribute :margin, Float
      attribute :margin_lr, Float
      attribute :margin_nlr, Float
      attribute :pnl, Float
      attribute :pnl_lr, Float
      attribute :pnl_nlr, Float
    end
  end
end
