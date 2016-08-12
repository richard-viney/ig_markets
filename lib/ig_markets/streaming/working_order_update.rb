module IGMarkets
  module Streaming
    # Contains details on a working order update received via the streaming API. Used by
    # {Streaming::Subscription#on_data}.
    class WorkingOrderUpdate < Model
      attribute :account_id
      attribute :channel
      attribute :deal_id
      attribute :deal_reference
      attribute :deal_status, Symbol, allowed_values: [:accepted, :rejected]
      attribute :direction, Symbol, allowed_values: [:buy, :sell]
      attribute :epic, String, regex: Regex::EPIC
      attribute :expiry, Date, nil_if: %w(- DFB), format: ['%d-%b-%y', '%b-%y']
      attribute :guaranteed_stop, Boolean
      attribute :level, Float
      attribute :limit_distance, Fixnum
      attribute :size, Float
      attribute :status, Symbol, allowed_values: [:deleted, :open, :updated]
      attribute :stop_distance, Fixnum
      attribute :timestamp, Time, format: '%FT%T'
    end
  end
end
