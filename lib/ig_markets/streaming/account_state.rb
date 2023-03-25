module IGMarkets
  module Streaming
    # This class tracks the current state of a dealing platform's accounts, positions and working orders by subscribing
    # to the relevant streaming data feeds supported by the IG Markets streaming API. This is much more efficient than
    # making repeated calls to the REST API to get current account, position or working order details, and also avoids
    # running into API traffic allowance limits.
    class AccountState
      # @return [Array<Account>] the current state of the accounts. The balances will be updated automatically as new
      #         streaming data arrives.
      attr_accessor :accounts

      # @return [Array<Position>] the current positions for this account. This set of positions will be updated
      #         automatically as new streaming data arrives.
      attr_accessor :positions

      # @return [Array<WorkingOrder>] the current working orders for this account. This set of working orders will be
      #         updated automatically as new streaming data arrives.
      attr_accessor :working_orders

      # Initializes this account state with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform

        @data_queue = Queue.new

        @market_subscriptions_manager = MarketSubscriptionManager.new dealing_platform
        @market_subscriptions_manager.on_data { |_data, merged_data| @data_queue << [:on_market_update, merged_data] }
      end

      # Starts all the relevant streaming subscriptions that are needed to keep this account state up to date using live
      # streaming updates. After this account state has been started the {#process_queued_data} method must be called
      # repeatedly to process the queue of streaming updates and apply them to {#accounts}, {#positions} and
      # {#working_orders} as appropriate.
      def start
        start_accounts_subscription
        start_trades_subscription

        @accounts = @dealing_platform.account.all
        @positions = @dealing_platform.positions.all
        @working_orders = @dealing_platform.working_orders.all

        @trades_subscription.unsilence

        update_market_subscriptions
      end

      # Returns whether the data queue is empty. If this returns false then there is data waiting to be processed by a
      # call to {#process_queued_data}.
      #
      # @return [Boolean]
      def data_queue_empty?
        @data_queue.empty?
      end

      # Processes all queued data and updates {#accounts}, {#positions} and {#working_orders} accordingly. If there are
      # no queued data updates then this method blocks until at least one data update is available.
      def process_queued_data
        loop do
          send(*@data_queue.pop)

          break if @data_queue.empty?
        end

        update_market_subscriptions
      end

      private

      def start_accounts_subscription
        @accounts_subscription = @dealing_platform.streaming.build_accounts_subscription

        @accounts_subscription.on_data do |_data, merged_data|
          @data_queue << [:on_account_update, merged_data]
        end

        @dealing_platform.streaming.start_subscriptions @accounts_subscription, snapshot: true
      end

      def start_trades_subscription
        @trades_subscription = @dealing_platform.streaming.build_trades_subscription

        @trades_subscription.on_data do |data|
          @data_queue << [:on_position_update, data] if data.is_a? PositionUpdate
          @data_queue << [:on_working_order_update, data] if data.is_a? WorkingOrderUpdate
        end

        @dealing_platform.streaming.start_subscriptions @trades_subscription, silent: true
      end

      def market_models
        @positions + @working_orders
      end

      def update_market_subscriptions
        @market_subscriptions_manager.epics = market_models.map { |model| model.market.epic }
      end

      def on_account_update(account_update)
        @accounts.each do |account|
          next unless account.account_id == account_update.account_id

          account.balance.available = account_update.available_to_deal
          account.balance.balance = account_update.equity
          account.balance.deposit = account_update.margin
          account.balance.profit_loss = account_update.pnl
        end
      end

      def on_market_update(market_update)
        market_models.each do |model|
          next unless model.market.epic == market_update.epic

          attributes_to_copy = { bid: :bid, high: :high, low: :low, net_change: :change, offer: :offer,
                                 percentage_change: :change_pct }

          attributes_to_copy.each do |target_attribute, update_attribute|
            model.market.send "#{target_attribute}=", market_update.send(update_attribute)
          end

          model.market.market_status = convert_market_status market_update.market_state if market_update.market_state
        end
      end

      def convert_market_status(status)
        {
          auction: :on_auction, auction_no_edit: :on_auction_no_edits, closed: :closed, edit: :edits_only,
          offline: :offline, suspended: :suspended, tradeable: :tradeable, tradeable_no_edit: :tradeable_no_edit
        }.fetch status
      end

      def on_position_update(position_update)
        send "on_position_#{position_update.status}", position_update
      end

      def on_position_open(position_update)
        return if @positions.any? { |position| position.deal_id == position_update.deal_id }

        new_position = @dealing_platform.positions[position_update.deal_id]

        @positions << new_position if new_position
      end

      def on_position_updated(position_update)
        @positions.each do |position|
          next unless position.deal_id == position_update.deal_id

          position.limit_level = position_update.limit_level
          position.stop_level = position_update.stop_level
        end
      end

      def on_position_deleted(position_update)
        @positions.delete_if do |position|
          position.deal_id == position_update.deal_id
        end
      end

      def on_working_order_update(working_order_update)
        send "on_working_order_#{working_order_update.status}", working_order_update
      end

      def on_working_order_open(working_order_update)
        return if @working_orders.any? { |working_order| working_order.deal_id == working_order_update.deal_id }

        new_working_order = @dealing_platform.working_orders[working_order_update.deal_id]

        @working_orders << new_working_order if new_working_order
      end

      def on_working_order_updated(working_order_update)
        working_order_attributes = %i[good_till_date limit_distance order_type stop_distance time_in_force]

        @working_orders.each do |working_order|
          next unless working_order.deal_id == working_order_update.deal_id

          working_order.currency_code = working_order_update.currency
          working_order.order_level = working_order_update.level

          working_order_attributes.each do |attribute|
            working_order.send "#{attribute}=", working_order_update.send(attribute)
          end
        end
      end

      def on_working_order_deleted(working_order_update)
        @working_orders.delete_if do |working_order|
          working_order.deal_id == working_order_update.deal_id
        end
      end
    end
  end
end
