module IGMarkets
  class WorkingOrder < Model
    attribute :created_date, type: :date_time, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :currency_code
    attribute :deal_id
    attribute :direction
    attribute :dma, type: :boolean
    attribute :epic
    attribute :good_till_date, type: :date_time, format: '%Y/%m/%d %H:%M'
    attribute :guaranteed_stop, type: :boolean
    attribute :limit_distance, type: :float
    attribute :order_level, type: :float
    attribute :order_size, type: :float
    attribute :order_type
    attribute :stop_distance, type: :float
    attribute :time_in_force

    attribute :market, type: Market
  end
end
