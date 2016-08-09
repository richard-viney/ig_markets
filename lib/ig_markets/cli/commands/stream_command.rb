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

          @dealing_platform.streaming.connect
          @dealing_platform.streaming.start_subscriptions subscriptions, snapshot: true

          loop { tick }
        end
      end

      private

      def subscriptions
        [accounts_subscription, markets_subscription, trades_subscription].compact
      end

      def accounts_subscription
        return unless options[:accounts]

        @dealing_platform.streaming.build_accounts_subscription
      end

      def markets_subscription
        return unless options[:markets]

        @dealing_platform.streaming.build_markets_subscription options[:markets]
      end

      def trades_subscription
        return unless options[:accounts]

        @dealing_platform.streaming.build_trades_subscription
      end

      def tick
        data = @dealing_platform.streaming.pop_data
        raise data if data.is_a? Lightstreamer::LightstreamerError

        process_new_data data[:data]
      end

      def process_new_data(data)
        if data.is_a? DealConfirmation
          data.affected_deals = nil
          data.date = nil
        end

        summary = data.attributes.keys.sort.map { |key| "#{key}: #{data.send key}" if data.send(key) }
        puts "#{data.class.name.split('::').last} - #{summary.compact.join ', '}"
      end
    end
  end
end
