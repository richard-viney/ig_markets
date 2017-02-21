module IGMarkets
  module CLI
    # Implements the `ig_markets self-test` command.
    class Main < Thor
      desc 'self-test', 'Runs a self-test of this application against the live IG Markets API (demo accounts only)'

      def self_test
        self.class.begin_session(options) do |dealing_platform|
          raise 'The self-test command must be run on a demo account' unless dealing_platform.session.platform == :demo

          @dealing_platform = dealing_platform
          run_self_test

          dealing_platform.sign_out
        end
      end

      private

      def run_self_test
        test_markets
        test_positions
        test_sprint_market_positions # not working on demo account ?
        test_working_orders
        test_watchlists
        test_client_sentiment
        test_account_methods
        test_applications
        test_streaming
      end

      def test_markets
        @dealing_platform.markets.hierarchy '264134' # ID of the main 'Forex' node
        @dealing_platform.markets.search 'EURUSD'
        @eur_usd = @dealing_platform.markets['CS.D.EURUSD.CFD.IP']
        @eur_usd_sprint = @dealing_platform.markets['FM.D.EURUSD24.EURUSD24.IP']
        @eur_usd.historical_prices resolution: :hour, number: 1
      end

      def test_positions
        test_position_create
        test_position_update
        test_position_close
      end

      def test_position_create
        deal_reference = @dealing_platform.positions.create currency_code: 'USD', direction: :buy,
                                                            epic: 'CS.D.EURUSD.CFD.IP', size: 2

        deal_confirmation = @dealing_platform.deal_confirmation deal_reference
        @position = @dealing_platform.positions[deal_confirmation.deal_id]

        raise 'Error: failed creating position' unless @position
      end

      def test_position_update
        stop_level = @position.level - 0.01

        @position.update stop_level: stop_level
        @position.reload

        update_worked = (@position.stop_level - stop_level).abs < 0.001

        raise 'Error: failed updating position' unless update_worked
      end

      def test_position_close
        @position.close

        raise 'Error: failed closing position' if @dealing_platform.positions[@position.deal_id]
      end

      def test_sprint_market_positions
        create_options = { direction: :buy, expiry_period: :sixty_minutes, epic: 'FM.D.EURUSD24.EURUSD24.IP',
                           size: 100 }

        deal_reference = @dealing_platform.sprint_market_positions.create create_options
        deal_confirmation = @dealing_platform.deal_confirmation deal_reference
        sprint_market_position = @dealing_platform.sprint_market_positions[deal_confirmation.deal_id]

        raise 'Error: failed creating sprint market position' unless sprint_market_position
      end

      def test_working_orders
        test_working_order_create
        test_working_order_update
        test_working_order_delete
      end

      def test_working_order_create
        deal_reference = @dealing_platform.working_orders.create currency_code: 'USD', direction: :buy,
                                                                 epic: 'CS.D.EURUSD.CFD.IP', type: :limit,
                                                                 level: @eur_usd.snapshot.bid - 0.1, size: 1

        @working_order = @dealing_platform.working_orders[@dealing_platform.deal_confirmation(deal_reference).deal_id]

        raise 'Error: failed creating working order' unless @working_order
      end

      def test_working_order_update
        new_level = @eur_usd.snapshot.bid - 1

        @working_order.update level: new_level
        @working_order.reload

        update_worked = (new_level - @dealing_platform.working_orders[@working_order.deal_id].order_level).abs < 0.01

        raise 'Error: failed updating working order' unless update_worked
      end

      def test_working_order_delete
        @working_order.delete

        raise 'Error: failed deleting working order' if @dealing_platform.working_orders[@working_order.deal_id]
      end

      def test_watchlists
        watchlist = @dealing_platform.watchlists.create SecureRandom.hex, 'UA.D.AAPL.CASH.IP'
        watchlist = @dealing_platform.watchlists[watchlist.id]
        watchlist.markets
        watchlist.add_market 'CS.D.EURUSD.CFD.IP'
        watchlist.remove_market 'CS.D.EURUSD.CFD.IP'
        watchlist.delete

        raise 'Error: failed deleting watchlist' if @dealing_platform.watchlists[watchlist.id]
      end

      def test_account_methods
        @dealing_platform.account.all
        @dealing_platform.account.activities from: Date.today - 14
        @dealing_platform.account.transactions from: Date.today - 14
      end

      def test_client_sentiment
        @dealing_platform.client_sentiment['EURUSD'].related_sentiments
      end

      def test_applications
        @dealing_platform.applications
      end

      def test_streaming
        streaming = @dealing_platform.streaming

        streaming.connect

        subscriptions = [streaming.build_accounts_subscription,
                         streaming.build_markets_subscription(['CS.D.EURUSD.CFD.IP']),
                         streaming.build_trades_subscription]

        streaming.start_subscriptions subscriptions, snapshot: true

        queue = Queue.new
        subscriptions.each { |subscription| subscription.on_data { |data| queue.push data } }
        10.times { queue.pop }

        streaming.disconnect
      end
    end
  end
end
