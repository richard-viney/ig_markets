module IGMarkets
  module Streaming
    # This class manages a single Lightstreamer subscription used to handle streaming data. Subscriptions should always
    # be created using the methods provided by {DealingPlatform::StreamingMethods}. Data can be consumed by registering
    # an asynchronous data callback using {#on_data}.
    class Subscription
      # The underlying Lightstreamer subscription being managed by this class.
      #
      # @return [Lightstreamer::Subscription]
      attr_reader :lightstreamer_subscription

      # Initializes this subscription with the specified dealing platform and Lightstreamer subscription.
      #
      # @param [DealingPlatform] dealing_platform
      # @param [Lightstreamer::Subscription] lightstreamer_subscription
      #
      # @private
      def initialize(dealing_platform, lightstreamer_subscription)
        @dealing_platform = dealing_platform

        @lightstreamer_subscription = lightstreamer_subscription
        @lightstreamer_subscription.on_data(&method(:on_raw_data))

        @on_data_callbacks = []
      end

      # Adds the passed block to the list of callbacks that will be run when this subscription receives new data. The
      # block will be called on a worker thread and so the code that is run by the block must be thread-safe. The
      # arguments passed to the block are `|data, merged_data|`, and the data will be an instance of {AccountUpdate},
      # {MarketUpdate}, {DealConfirmation}, {PositionUpdate}, {WorkingOrderUpdate}, {ConsolidatedChartDataUpdate} or
      # {ChartTickUpdate}, depending on what was subscribed to. The `merged_data` argument will be `nil` for deal
      # confirmations, position updates, working order updates, and chart tick updates.
      #
      # @param [Proc] callback The callback that is to be run.
      def on_data(&callback)
        @on_data_callbacks << callback
      end

      private

      ACCOUNT_DATA_REGEX = /^ACCOUNT:(.*)$/
      MARKET_DATA_REGEX = /^MARKET:(.*)$/
      TRADE_DATA_REGEX = /^TRADE:(.*)$/
      CHART_TICK_DATA_REGEX = /^CHART:(.*):TICK$/
      CONSOLIDATED_CHART_DATA_REGEX = /^CHART:(.*):(SECOND|1MINUTE|5MINUTE|HOUR)$/

      def on_raw_data(subscription, item_name, item_data, new_data)
        on_account_data subscription, item_name, item_data, new_data if item_name =~ ACCOUNT_DATA_REGEX
        on_market_data subscription, item_name, item_data, new_data if item_name =~ MARKET_DATA_REGEX
        on_trade_data subscription, item_name, item_data, new_data if item_name =~ TRADE_DATA_REGEX
        on_chart_tick_data subscription, item_name, item_data, new_data if item_name =~ CHART_TICK_DATA_REGEX

        if item_name =~ CONSOLIDATED_CHART_DATA_REGEX
          on_consolidated_chart_data subscription, item_name, item_data, new_data
        end
      end

      def on_account_data(_subscription, item_name, item_data, new_data)
        item_data = @dealing_platform.instantiate_models AccountUpdate, item_data
        new_data = @dealing_platform.instantiate_models AccountUpdate, new_data

        item_data.account_id = item_name.match(ACCOUNT_DATA_REGEX).captures.first
        new_data.account_id = item_data.account_id

        run_callbacks new_data, item_data
      end

      def on_market_data(_subscription, item_name, item_data, new_data)
        item_data = @dealing_platform.instantiate_models MarketUpdate, item_data
        new_data = @dealing_platform.instantiate_models MarketUpdate, new_data

        item_data.epic = item_name.match(MARKET_DATA_REGEX).captures.first
        new_data.epic = item_data.epic

        run_callbacks new_data, item_data
      end

      def on_trade_data(_subscription, item_name, _item_data, new_data)
        account_id = item_name.match(TRADE_DATA_REGEX).captures.first

        { confirms: DealConfirmation, opu: PositionUpdate, wou: WorkingOrderUpdate }.each do |key, model_class|
          next unless new_data[key]

          data = @dealing_platform.instantiate_models_from_json model_class, new_data[key]
          data.account_id = account_id

          run_callbacks data
        end
      end

      def on_chart_tick_data(_subscription, item_name, _item_data, new_data)
        new_data = @dealing_platform.instantiate_models ChartTickUpdate, new_data

        new_data.epic = item_name.match(CHART_TICK_DATA_REGEX).captures.first

        run_callbacks new_data
      end

      def on_consolidated_chart_data(_subscription, item_name, item_data, new_data)
        item_data = @dealing_platform.instantiate_models ConsolidatedChartDataUpdate, item_data
        new_data = @dealing_platform.instantiate_models ConsolidatedChartDataUpdate, new_data

        captures = item_name.match(CONSOLIDATED_CHART_DATA_REGEX).captures
        item_data.epic = new_data.epic = captures[0]
        item_data.scale = new_data.scale = { 'SECOND' => :one_second, '1MINUTE' => :one_minute,
                                             '5MINUTE' => :five_minutes, 'HOUR' => :one_hour }.fetch captures[1]

        run_callbacks new_data, item_data
      end

      def run_callbacks(data, merged_data = nil)
        @on_data_callbacks.each { |block| block.call data, merged_data }
      end
    end
  end
end
