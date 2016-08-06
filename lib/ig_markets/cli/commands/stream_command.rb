module IGMarkets
  module CLI
    # Implements the `ig_markets stream` command.
    class Main < Thor
      desc 'stream', 'Displays live streaming updates of account balances, markets and trading activity'

      option :accounts, type: :boolean, desc: 'Whether to stream changes to account balances'
      option :markets, type: :array, desc: 'The EPICs of the markets to stream live prices for'
      option :trades, type: :boolean, desc: 'Whether to stream details of any trades and position or order updates'

      def stream
        self.class.begin_session(options) do |dealing_platform|
          @dealing_platform = dealing_platform

          prepare_stream

          loop { process_new_data @queue.pop }
        end
      end

      private

      def process_new_data(data)
        raise data if data.is_a? Lightstreamer::LightstreamerError

        puts data
      end

      def prepare_stream
        @queue = Queue.new

        @lightstreamer = @dealing_platform.lightstreamer_session
        @lightstreamer.on_error { |error| @queue.push error }
        @lightstreamer.connect

        subscriptions = [account_subscription, market_subscription, trade_subscription].compact
        @lightstreamer.bulk_subscription_start subscriptions, snapshot: true
      end

      def account_subscription
        return unless options[:accounts]

        items = @dealing_platform.client_account_summary.accounts.map { |account| "ACCOUNT:#{account.account_id}" }
        fields = [:pnl, :deposit, :available_cash, :funds, :margin, :available_to_deal, :equity]

        subscription = @lightstreamer.build_subscription items: items, fields: fields, mode: :merge

        subscription.on_data do |_subscription, item_name, item_data, _new_data|
          @queue.push "#{item_name} - #{item_data.map { |key, value| "#{key}: #{value}" }.join ', '}"
        end

        subscription
      end

      def market_subscription
        items = Array(options[:markets]).map { |market| "MARKET:#{market}" }
        fields = [:bid, :offer, :high, :low, :mid_open, :strike_price, :odds]

        subscription = @lightstreamer.build_subscription items: items, fields: fields, mode: :merge

        subscription.on_data do |_subscription, item_name, item_data, _new_data|
          @queue.push "#{item_name} - #{item_data.map { |key, value| "#{key}: #{value}" }.join ', '}"
        end

        subscription
      end

      def trade_subscription
        return unless options[:trades]

        items = @dealing_platform.client_account_summary.accounts.map { |account| "TRADE:#{account.account_id}" }
        fields = [:confirms, :opu, :wou]

        subscription = @lightstreamer.build_subscription items: items, fields: fields, mode: :distinct
        subscription.on_data(&method(:on_trade_data))

        subscription
      end

      def on_trade_data(_subscription, item_name, item_data, _new_data)
        {
          confirms: [:format_confirmation, DealConfirmation, 'Confirmation'],
          opu: [:format_position_update, PositionUpdate, 'Position update'],
          wou: [:format_working_order_update, WorkingOrderUpdate, 'Order update']
        }.each do |key, (handler_method, model_class, title)|
          next unless item_data[key]

          model = @dealing_platform.instantiate_models_from_json model_class, item_data[key]

          @queue.push "#{item_name} - #{title} - id: #{model.deal_id}#{send handler_method, model}"
        end
      end

      def format_confirmation(model)
        queue_item = format_attributes model, [:status, :deal_status, :epic, :direction, :size, :level, :stop_distance,
                                               :stop_level, :limit_distance, :limit_level]

        queue_item << ", profit: #{Format.currency(model.profit, model.profit_currency)}" if model.profit

        queue_item
      end

      def format_position_update(model)
        format_attributes model, [:status, :deal_status, :epic, :direction, :size, :level, :stop_level, :limit_level]
      end

      def format_working_order_update(model)
        format_attributes model, [:status, :deal_status, :epic, :direction, :size, :level, :stop_distance,
                                  :limit_distance]
      end

      def format_attributes(model, attributes)
        attributes.each_with_object('') do |attribute, result|
          value = model.send attribute
          result << ", #{attribute}: #{value}" if value
        end
      end

      # Internal model used to parse streaming position updates.
      class PositionUpdate < Model
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

      # Internal model used to parse streaming working order updates.
      class WorkingOrderUpdate < Model
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
        attribute :timestamp, Time, format: '%FT%T.%L'
      end
    end
  end
end
