module IGMarkets
  module Streaming
    # This class manages a set of streaming subscriptions for a changing set of EPICs. The set of EPICs to stream data
    # for is set by calls to {#epics=}, and when streaming market data becomes available it is passed to all registered
    # {#on_data} callbacks.
    #
    # This class can be used standalone, but its primary function is as a helper for the {AccountState} class.
    class MarketSubscriptionManager
      # Initializes this market subscription manager with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform

        @subscriptions = {}
        @on_data_callbacks = []
      end

      # Removes all market subscriptions and data callbacks.
      def clear
        @dealing_platform.streaming.remove_subscriptions @subscriptions.values

        @subscriptions = {}
        @on_data_callbacks = []
      end

      # Adds the passed block to the list of callbacks that will be run when a market that is subscribed to receives new
      # data. The block will be called on a worker thread and so the code that is run by the block must be thread-safe.
      # The arguments passed to the block are `|data, merged_data|`, and both arguments will be instances of
      # {MarketUpdate}.
      #
      # @param [Proc] callback The callback that is to be run.
      def on_data(&callback)
        @on_data_callbacks << callback
      end

      # Sets the EPICs that this market subscription manager should be subscribed to and notifying updates for through
      # {#on_data}.
      #
      # @param [Array<String>] epics
      def epics=(epics)
        epics = Array(epics).uniq

        create_missing_subscriptions epics
        remove_unused_subscriptions epics
      end

      private

      def create_missing_subscriptions(epics)
        new_subscriptions = []

        epics.each do |epic|
          next if @subscriptions.key? epic

          subscription = @dealing_platform.streaming.build_markets_subscription epic
          subscription.on_data(&method(:run_callbacks))

          @subscriptions[epic] = subscription

          new_subscriptions << subscription
        end

        @dealing_platform.streaming.start_subscriptions new_subscriptions, snapshot: true
      end

      def remove_unused_subscriptions(epics)
        old_subscriptions = []

        @subscriptions.each_key do |epic|
          next if epics.include? epic

          old_subscriptions << @subscriptions.delete(epic)
        end

        @dealing_platform.streaming.remove_subscriptions old_subscriptions
      end

      def run_callbacks(data, merged_data)
        @on_data_callbacks.each do |callback|
          callback.call data, merged_data
        end
      end
    end
  end
end
