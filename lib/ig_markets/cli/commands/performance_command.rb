module IGMarkets
  module CLI
    # Implements the `ig_markets performance` command.
    class Main
      desc 'performance', 'Prints a summary of trading performance over a period'

      option :days, type: :numeric, required: true, desc: 'The number of days to print performance for'
      option :from, desc: 'The date and time to show performance from, format: yyyy-mm-ddThh:mm:ss'

      def performance
        self.class.begin_session(options) do |dealing_platform|
          performances = gather_performances dealing_platform
          lookup_instrument_names performances, dealing_platform

          table = PerformancesTable.new performances

          puts table

          print_summary performances
        end
      end

      private

      def gather_performances(dealing_platform)
        performances = deal_transactions_by_epic(dealing_platform).map do |epic, transactions|
          profit_loss = transactions.map(&:profit_and_loss_amount).inject(&:+)

          { epic: epic, transactions: transactions, profit_loss: profit_loss }
        end

        performances.sort_by { |a| a[:profit_loss] }
      end

      def deal_transactions_by_epic(dealing_platform)
        activities = dealing_platform.account.activities history_options

        deal_transactions(dealing_platform).group_by do |transaction|
          activities.detect do |activity|
            Regexp.new("^Position(\/s| partially) closed:.*#{transaction.reference}").match activity.description
          end.epic
        end
      end

      def deal_transactions(dealing_platform)
        dealing_platform.account.transactions(history_options).select do |transaction|
          transaction.transaction_type == :deal
        end
      end

      def lookup_instrument_names(performances, dealing_platform)
        markets = dealing_platform.markets.find(*performances.map { |a| a[:epic] })

        performances.each do |a|
          a[:instrument_name] = markets.detect { |market| market.instrument.epic == a[:epic] }.instrument.name
        end
      end

      def print_summary(performances)
        profit_loss = performances.map { |h| h[:profit_loss] }.inject(:+)
        currency = performances.first[:transactions].first.currency

        puts <<-END

Note: this table only shows the profit/loss made from dealing, it does not include interest payments,
      dividends, or other adjustments that may have occurred over this period.

Total: #{Format.colored_currency profit_loss, currency}
END
      end
    end
  end
end
