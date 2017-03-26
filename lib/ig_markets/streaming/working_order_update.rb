module IGMarkets
  module Streaming
    # Contains details on a working order update received via the streaming API. Used by
    # {Streaming::Subscription#on_data}.
    class WorkingOrderUpdate < Model
      attribute :account_id
      attribute :channel
      attribute :currency, String, regex: Regex::CURRENCY
      attribute :deal_id
      attribute :deal_reference
      attribute :deal_status, Symbol, allowed_values: [:accepted, :rejected]
      attribute :direction, Symbol, allowed_values: [:buy, :sell]
      attribute :epic, String, regex: Regex::EPIC
      attribute :expiry, Date, nil_if: %w(- DFB), format: ['%d-%b-%y', '%b-%y']
      attribute :good_till_date, Time, format: '%FT%T'
      attribute :guaranteed_stop, Boolean
      attribute :level, Float
      attribute :limit_distance, Integer
      attribute :order_type, Symbol, allowed_values: [:limit, :stop]
      attribute :size, Float
      attribute :status, Symbol, allowed_values: [:deleted, :open, :updated]
      attribute :stop_distance, Integer
      attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]
      attribute :timestamp, Time, format: ['%FT%T.%L', '%FT%T']
    end
  end
end
