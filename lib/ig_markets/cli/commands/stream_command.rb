module IGMarkets
  module CLI
    # Implements the `ig_markets stream` command.
    class Stream < Thor
      desc 'raw', 'Displays raw live streaming updates of account balances, markets and trading activity'

      option :accounts, type: :boolean, desc: 'Whether to stream changes to account balances'
      option :markets, type: :array, desc: 'The EPICs of the markets to stream live prices for'
      option :trades, type: :boolean, desc: 'Whether to stream details of any trades and position or order updates'
      option :chart_ticks, type: :array, desc: 'The EPICs of the markets to stream live chart tick data for'

      def raw
        Main.begin_session(options) do |dealing_platform|
          @dealing_platform = dealing_platform
          @queue = Queue.new

          @dealing_platform.streaming.on_error(&method(:on_error))
          @dealing_platform.streaming.connect
          start_subscriptions

          main_loop
        end
      end

      private

      def start_subscriptions
        subscriptions = [accounts_subscription, markets_subscription, trades_subscription,
                         chart_ticks_subscription].compact

        subscriptions.each do |subscription|
          subscription.on_data(&method(:on_data))
        end

        @dealing_platform.streaming.start_subscriptions subscriptions, snapshot: true
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
        return unless options[:trades]

        @dealing_platform.streaming.build_trades_subscription
      end

      def chart_ticks_subscription
        return unless options[:chart_ticks]

        @dealing_platform.streaming.build_chart_ticks_subscription options[:chart_ticks]
      end

      def on_data(data, _merged_data)
        if data.is_a? DealConfirmation
          data.affected_deals = nil
          data.date = nil
        end

        summary = data.attributes.keys.sort.map { |key| "#{key}: #{data.send key}" if data.send key }

        @queue.push "#{data.class.name.split('::').last} - #{summary.compact.join ', '}"
      end

      def on_error(error)
        @queue.push error
      end

      def main_loop
        loop do
          data = @queue.pop
          raise data if data.is_a? Lightstreamer::LightstreamerError

          puts data
        end
      end
    end
  end
end
