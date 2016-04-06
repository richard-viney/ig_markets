module IGMarkets
  # Contains details on a single dealing event. Returned by {DealingPlatform#deal_confirmation}.
  class DealConfirmation < Model
    # Contains details on a specific deal that was affected by a dealing event. Returned by {#affected_deals}.
    class AffectedDeal < Model
      attribute :deal_id
      attribute :status, Symbol, allowed_values: [:amended, :deleted, :fully_closed, :opened, :partially_closed]
    end

    attribute :affected_deals, AffectedDeal
    attribute :deal_id
    attribute :deal_reference
    attribute :deal_status, Symbol, allowed_values: [:accepted, :fund_account, :rejected]
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :epic
    attribute :expiry, DateTime, nil_if: '-', format: '%d-%b-%y'
    attribute :guaranteed_stop, Boolean
    attribute :level, Float
    attribute :limit_distance, Float
    attribute :limit_level, Float
    attribute :reason, Symbol, allowed_values: [
      :account_not_enabled_to_trading, :attached_order_level_error, :attached_order_trailing_stop_error,
      :cannot_change_stop_type, :cannot_remove_stop, :closing_only_trades_accepted_on_this_market, :conflicting_order,
      :cr_spacing, :duplicate_order_error, :exchange_manual_override, :finance_repeat_dealing,
      :force_open_on_same_market_different_currency, :general_error, :good_till_date_in_the_past, :instrument_not_found,
      :insufficient_funds, :level_tolerance_error, :manual_order_timeout, :market_closed, :market_closed_with_edits,
      :market_closing, :market_not_borrowable, :market_offline, :market_phone_only, :market_rolled,
      :market_unavailable_to_client, :max_auto_size_exceeded, :minimum_order_size_error, :move_away_only_limit,
      :move_away_only_stop, :move_away_only_trigger_level, :opposing_direction_orders_not_allowed,
      :opposing_positions_not_allowed, :order_locked, :order_not_found, :over_normal_market_size,
      :partially_closed_position_not_deleted, :position_not_available_to_close, :position_not_found,
      :reject_spreadbet_order_on_cfd_account, :size_increment, :sprint_market_expiry_after_market_close,
      :stop_or_limit_not_allowed, :stop_required_error, :strike_level_tolerance, :success, :trailing_stop_not_allowed,
      :unknown, :wrong_side_of_market]
    attribute :size, Fixnum
    attribute :status, Symbol, allowed_values: [:amended, :closed, :deleted, :open, :partially_closed]
    attribute :stop_distance, Float
    attribute :stop_level, Float
    attribute :trailing_stop, Boolean
  end
end
