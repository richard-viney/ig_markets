module IGMarkets
  module CLI
    # Implements the `ig_markets stream` command.
    class Stream < Thor
      desc 'dashboard', 'Displays an updating live display of account balances, positions and working orders'

      option :aggregate, type: :boolean, desc: 'Whether to aggregate separate positions in the same market'

      def dashboard
        Main.begin_session(options) do |dealing_platform|
          dealing_platform.streaming.connect
          dealing_platform.streaming.on_error { |error| @error = error }

          window = CursesWindow.new

          account_state = Streaming::AccountState.new dealing_platform
          account_state.start

          redraw_account_state account_state, window until @error

          raise @error
        end
      end

      default_task :dashboard

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
          start_raw_subscriptions

          main_loop
        end
      end

      private

      def start_raw_subscriptions
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

      def redraw_account_state(account_state, window)
        account_state.process_queued_data

        window.clear
        window.print_lines window_content(account_state)
        window.refresh

        sleep 0.5
      end

      def window_content(account_state)
        [Tables::AccountsTable.new(account_state.accounts).lines, '',
         Tables::PositionsTable.new(account_state.positions, aggregate: options[:aggregate]).lines, '',
         Tables::WorkingOrdersTable.new(account_state.working_orders).lines, '']
      end
    end
  end
end
