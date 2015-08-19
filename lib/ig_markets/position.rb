module IGMarkets
  class Position < Model
    attribute :contract_size, type: :float
    attribute :controlled_risk, type: :boolean
    attribute :created_date, type: :date_time, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :currency
    attribute :deal_id
    attribute :direction
    attribute :level, type: :float
    attribute :limit_level, type: :float
    attribute :size, type: :float
    attribute :stop_level, type: :float
    attribute :trailing_step, type: :float
    attribute :trailing_stop_distance, type: :float

    attribute :market, type: Market
  end
end
