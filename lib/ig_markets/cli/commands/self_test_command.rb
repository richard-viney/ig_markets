module IGMarkets
  module CLI
    # Implements the `ig_markets self-test` command.
    class Main < Thor
      desc 'self-test', 'Runs a self-test of this application against the live IG Markets API (demo accounts only)'

      def self_test
        self.class.begin_session(options) do |dealing_platform|
          raise 'Error: self-tests must be run on a demo account' unless dealing_platform.session.platform == :demo

          run_self_test dealing_platform

          dealing_platform.sign_out
        end
      end

      private

      def run_self_test(dealing_platform)
        test_markets dealing_platform
        test_positions dealing_platform
        test_sprint_market_positions dealing_platform
        test_working_orders dealing_platform
        test_watchlists dealing_platform
        test_client_sentiment dealing_platform
        test_account_methods dealing_platform
        test_applications dealing_platform
      end

      def test_markets(dealing_platform)
        dealing_platform.markets.hierarchy '264134' # ID of the main 'Forex' node
        dealing_platform.markets.search 'EURUSD'
        @eur_usd = dealing_platform.markets['CS.D.EURUSD.CFD.IP']
        @eur_usd_sprint = dealing_platform.markets['FM.D.EURUSD24.EURUSD24.IP']
        @eur_usd.historical_prices resolution: :hour, number: 1
      end

      def test_positions(dealing_platform)
        test_position_create dealing_platform
        test_position_update
        test_position_close dealing_platform
      end

      def test_position_create(dealing_platform)
        deal_reference = dealing_platform.positions.create currency_code: 'USD', direction: :buy,
                                                           epic: 'CS.D.EURUSD.CFD.IP', size: 2

        @position = dealing_platform.positions[dealing_platform.deal_confirmation(deal_reference).deal_id]

        raise 'Error: failed creating position' unless @position
      end

      def test_position_update
        stop_level = @position.level - 0.01

        @position.update stop_level: stop_level
        @position.reload

        update_worked = (@position.stop_level - stop_level).abs < 0.001

        raise 'Error: failed updating position' unless update_worked
      end

      def test_position_close(dealing_platform)
        @position.close

        raise 'Error: failed closing position' if dealing_platform.positions[@position.deal_id]
      end

      def test_sprint_market_positions(dealing_platform)
        deal_reference = dealing_platform.sprint_market_positions.create direction: :buy,
                                                                         epic: 'FM.D.EURUSD24.EURUSD24.IP',
                                                                         expiry_period: :twenty_minutes, size: 100

        deal_confirmation = dealing_platform.deal_confirmation deal_reference

        sprint_market_position = dealing_platform.sprint_market_positions[deal_confirmation.deal_id]

        raise 'Error: failed creating sprint market position' unless sprint_market_position
      end

      def test_working_orders(dealing_platform)
        test_working_order_create dealing_platform
        test_working_order_update dealing_platform
        test_working_order_delete dealing_platform
      end

      def test_working_order_create(dealing_platform)
        deal_reference = dealing_platform.working_orders.create currency_code: 'USD', direction: :buy,
                                                                epic: 'CS.D.EURUSD.CFD.IP', type: :limit,
                                                                level: @eur_usd.snapshot.bid - 0.1, size: 1

        @working_order = dealing_platform.working_orders[dealing_platform.deal_confirmation(deal_reference).deal_id]

        raise 'Error: failed creating working order' unless @working_order
      end

      def test_working_order_update(dealing_platform)
        new_level = @eur_usd.snapshot.bid - 1

        @working_order.update level: new_level
        @working_order.reload

        update_worked = (new_level - dealing_platform.working_orders[@working_order.deal_id].order_level).abs < 0.01

        raise 'Error: failed updating working order' unless update_worked
      end

      def test_working_order_delete(dealing_platform)
        @working_order.delete

        raise 'Error: failed deleting working order' if dealing_platform.working_orders[@working_order.deal_id]
      end

      def test_watchlists(dealing_platform)
        watchlist = dealing_platform.watchlists.create SecureRandom.hex, 'UA.D.AAPL.CASH.IP'
        watchlist = dealing_platform.watchlists[watchlist.id]
        watchlist.markets
        watchlist.add_market 'CS.D.EURUSD.CFD.IP'
        watchlist.remove_market 'CS.D.EURUSD.CFD.IP'
        watchlist.delete

        raise 'Error: failed deleting watchlist' if dealing_platform.watchlists[watchlist.id]
      end

      def test_account_methods(dealing_platform)
        dealing_platform.account.all
        dealing_platform.account.activities from: Date.today - 14
        dealing_platform.account.transactions from: Date.today - 14
      end

      def test_client_sentiment(dealing_platform)
        client_sentiment = dealing_platform.client_sentiment['EURUSD']
        client_sentiment.related_sentiments
      end

      def test_applications(dealing_platform)
        dealing_platform.applications
      end
    end
  end
end
