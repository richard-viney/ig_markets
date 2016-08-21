module IGMarkets
  class DealingPlatform
    # Provides methods for working with streaming of IG Markets data. Returned by {DealingPlatform#streaming}.
    class StreamingMethods
      # Initializes this class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = WeakRef.new dealing_platform
        @queue = Queue.new
        @on_error_callbacks = []
      end

      # Connects the streaming session. Raises a `Lightstreamer::LightstreamerError` if an error occurs.
      def connect
        @lightstreamer.disconnect if @lightstreamer
        @queue.clear

        @lightstreamer = Lightstreamer::Session.new username: username, password: password, server_url: server_url
        @lightstreamer.on_error { |error| @on_error_callbacks.each { |callback| callback.call error } }
        @lightstreamer.connect
      end

      # Disconnects the streaming session.
      def disconnect
        @lightstreamer.disconnect if @lightstreamer
        @lightstreamer = nil
      end

      # Adds the passed block to the list of callbacks that will be run when the streaming session encounters an error.
      # The block will be called on a worker thread and so the code that is run by the block must be thread-safe.
      # The argument passed to the block is `|error|`, which will be a `Lightstreamer::LightstreamerError` subclass
      # detailing the error that occurred.
      #
      # @param [Proc] callback The callback that is to be run.
      def on_error(&callback)
        @on_error_callbacks << callback
      end

      # Creates a new subscription for balance updates on the specified account(s). The returned
      # {Streaming::Subscription} must be passed to {#start_subscriptions} in order to actually start streaming its
      # data.
      #
      # @param [Array<#account_id>, nil] accounts The accounts to create a subscription for. If this is `nil` then the
      #        new subscription will apply to all the accounts for the active client.
      #
      # @return [Streaming::Subscription]
      def build_accounts_subscription(accounts = nil)
        accounts ||= @dealing_platform.client_account_summary.accounts

        items = Array(accounts).map { |account| "ACCOUNT:#{account.account_id}" }
        fields = [:available_cash, :available_to_deal, :deposit, :equity, :equity_used, :funds, :margin, :margin_lr,
                  :margin_nlr, :pnl, :pnl_lr, :pnl_nlr]

        build_subscription items: items, fields: fields, mode: :merge
      end

      # Creates a new Lightstreamer subscription for updates to the specified market(s). The returned
      # {Streaming::Subscription} must be passed to {#start_subscriptions} in order to actually start streaming its
      # data.
      #
      # @param [Array<String>] epics The EPICs of the markets to create a subscription for.
      #
      # @return [Streaming::Subscription]
      def build_markets_subscription(epics)
        items = Array(epics).map { |epic| "MARKET:#{epic}" }
        fields = [:bid, :change, :change_pct, :high, :low, :market_delay, :market_state, :mid_open, :odds, :offer,
                  :strike_price, :update_time]

        build_subscription items: items, fields: fields, mode: :merge
      end

      # Creates a new Lightstreamer subscription for trade, position and working order updates on the specified
      # account(s). The returned {Streaming::Subscription} must be passed to {#start_subscriptions} in order to
      # actually start streaming its data.
      #
      # @param [Array<#account_id>, nil] accounts The accounts to create a subscription for. If this is `nil` then the
      #        new subscription will apply to all the accounts for the active client.
      #
      # @return [Streaming::Subscription]
      def build_trades_subscription(accounts = nil)
        accounts ||= @dealing_platform.client_account_summary.accounts

        items = Array(accounts).map { |account| "TRADE:#{account.account_id}" }
        fields = [:confirms, :opu, :wou]

        build_subscription items: items, fields: fields, mode: :distinct
      end

      # Creates a new Lightstreamer subscription for chart tick data for the specified EPICs. The returned
      # {Streaming::Subscription} must be passed to {#start_subscriptions} in order to actually start streaming its
      # data.
      #
      # @param [Array<String>] epics The EPICs of the markets to create a chart tick data subscription for.
      #
      # @return [Streaming::Subscription]
      def build_chart_ticks_subscription(epics)
        items = Array(epics).map { |epic| "CHART:#{epic}:TICK" }
        fields = [:bid, :day_high, :day_low, :day_net_chg_mid, :day_open_mid, :day_perc_chg_mid, :ltp, :ltv, :ofr, :ttv,
                  :utm]

        build_subscription items: items, fields: fields, mode: :distinct
      end

      # Creates a new Lightstreamer subscription for consolidated chart data for the specified EPIC and scale. The
      # returned {Streaming::Subscription} must be passed to {#start_subscriptions} in order to actually start streaming
      # its data.
      #
      # @param [String] epic The EPIC of the market to create a consolidated chart data subscription for.
      # @param [:one_second, :one_minute, :five_minutes, :one_hour] scale The scale of the consolidated data.
      #
      # @return [Streaming::Subscription]
      def build_consolidated_chart_data_subscription(epic, scale)
        scale = { one_second: 'SECOND', one_minute: '1MINUTE', five_minutes: '5MINUTE', one_hour: 'HOUR' }.fetch scale
        items = ["CHART:#{epic}:#{scale}"]

        fields = [:bid_close, :bid_high, :bid_low, :bid_open, :cons_end, :cons_tick_count, :day_high, :day_low,
                  :day_net_chg_mid, :day_open_mid, :day_perc_chg_mid, :ltp_close, :ltp_high, :ltp_low, :ltp_open, :ltv,
                  :ofr_close, :ofr_high, :ofr_low, :ofr_open, :ttv, :utm]

        build_subscription items: items, fields: fields, mode: :merge
      end

      # Starts streaming data from the passed Lightstreamer subscription(s). The return value indicates the error state,
      # if any, for each subscription.
      #
      # @param [Array<Streaming::Subscription>] subscriptions
      # @param [Hash] options The options to start the subscriptions with. See the documentation for
      #        `Lightstreamer::Subscription#start` for details of the accepted options.
      #
      # @return [Array<Lightstreamer::LightstreamerError, nil>] An array with one entry per subscription which indicates
      #         the error state returned for that subscription's start request, or `nil` if no error occurred.
      def start_subscriptions(subscriptions, options = {})
        lightstreamer_subscriptions = Array(subscriptions).compact.map(&:lightstreamer_subscription)

        return if lightstreamer_subscriptions.empty?

        @lightstreamer.start_subscriptions lightstreamer_subscriptions, options
      end

      # Stops streaming data for the specified subscription(s) and removes them from the streaming session.
      #
      # @param [Array<Lightstreamer::Subscription>] subscriptions The subscriptions to stop.
      def remove_subscriptions(subscriptions)
        lightstreamer_subscriptions = Array(subscriptions).compact.map(&:lightstreamer_subscription)

        return if lightstreamer_subscriptions.empty?

        @lightstreamer.remove_subscriptions lightstreamer_subscriptions
      end

      private

      def username
        @dealing_platform.client_account_summary.client_id
      end

      def password
        "CST-#{@dealing_platform.session.client_security_token}|XST-#{@dealing_platform.session.x_security_token}"
      end

      def server_url
        @dealing_platform.client_account_summary.lightstreamer_endpoint
      end

      def build_subscription(options)
        subscription = @lightstreamer.build_subscription options

        Streaming::Subscription.new @dealing_platform, subscription
      end
    end
  end
end
