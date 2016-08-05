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

        subscription.on_data do |_subscription, item_name, item_data, _new_data|
          process_confirmation item_name, item_data[:confirms]
          process_position_update item_name, item_data[:opu]
          process_working_order_update item_name, item_data[:wou]
        end

        subscription
      end

      def process_confirmation(item_name, json)
        return unless json

        model = DealConfirmation.new ResponseParser.parse(JSON.parse(json)).merge(affected_deals: nil)

        queue_item = "#{item_name} - Confirmation - id: #{model.deal_id}"

        [:status, :deal_status, :epic, :direction, :size, :level, :stop_distance, :stop_level, :limit_distance,
         :limit_level].each do |attribute|
          value = model.send attribute
          queue_item << ", #{attribute}: #{value}" if value
        end

        queue_item << ", profit: #{Format.currency(model.profit, model.profit_currency)}" if model.profit

        @queue.push queue_item
      end

      def process_position_update(item_name, json)
        return unless json

        model = OpenPositionUpdate.new ResponseParser.parse(JSON.parse(json))

        queue_item = "#{item_name} - Position update - id: #{model.deal_id}"

        [:status, :deal_status, :epic, :direction, :size, :level, :stop_level, :limit_level].each do |attribute|
          value = model.send attribute
          queue_item << ", #{attribute}: #{value}" if value
        end

        @queue.push queue_item
      end

      def process_working_order_update(item_name, json)
        return unless json

        model = WorkingOrderUpdate.new ResponseParser.parse(JSON.parse(json))

        queue_item = "#{item_name} - Order update - id: #{model.deal_id}"

        [:status, :deal_status, :epic, :direction, :size, :level, :stop_distance, :limit_distance].each do |attribute|
          value = model.send attribute
          queue_item << ", #{attribute}: #{value}" if value
        end

        @queue.push queue_item
      end

      # Internal model used to parse streaming open position updates.
      class OpenPositionUpdate < Model
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
