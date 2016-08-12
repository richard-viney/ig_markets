module IGMarkets
  module Streaming
    # Contains details on a position update received via the streaming API. Used by {Streaming::Subscription#on_data}.
    class PositionUpdate < Model
      attribute :account_id
      attribute :channel
      attribute :deal_id
      attribute :deal_id_origin
      attribute :deal_reference
      attribute :deal_status, Symbol, allowed_values: [:accepted, :rejected]
      attribute :direction, Symbol, allowed_values: [:buy, :sell]
      attribute :epic, String, regex: Regex::EPIC
      attribute :expiry, Date, nil_if: %w(- DFB), format: ['%d-%b-%y', '%b-%y']
      attribute :guaranteed_stop, Boolean
      attribute :level, Float
      attribute :limit_level, Float
      attribute :size, Float
      attribute :status, Symbol, allowed_values: [:deleted, :open, :updated]
      attribute :stop_level, Float
      attribute :timestamp, Time, format: '%FT%T.%L'
    end
  end
end