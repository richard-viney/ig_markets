module IGMarkets
  class DealConfirmation < Model
    class AffectedDeal < Model
      attribute :deal_id
      attribute :status
    end

    attribute :affected_deals, type: AffectedDeal
    attribute :deal_id
    attribute :deal_reference
    attribute :deal_status
    attribute :direction
    attribute :epic
    attribute :expiry
    attribute :guaranteed_stop
    attribute :level
    attribute :limit_distance
    attribute :limit_level
    attribute :reason
    attribute :size, type: :float
    attribute :status
    attribute :stop_distance, type: :float
    attribute :stop_level, type: :float
    attribute :trailing_stop, type: :boolean
  end
end
