module IGMarkets
  module CLI
    # Implements the `ig_markets performance` command.
    class Main
      desc 'performance', 'Prints a summary of trading performance over a period'

      option :days, type: :numeric, required: true, desc: 'The number of days to print performance for'
      option :from, desc: 'The start date to show performance from, format: yyyy-mm-dd'

      def performance
        self.class.begin_session(options) do |dealing_platform|
          performances = deal_transactions_by_epic(dealing_platform).map do |epic, transactions|
            profit_loss = transactions.map(&:profit_and_loss_amount).inject(&:+)

            { epic: epic, transactions: transactions, profit_loss: profit_loss }
          end

          performances.sort_by! { |a| a[:profit_loss] }

          table = PerformancesTable.new performances

          puts table

          print_summary performances
        end
      end

      private

      def deal_transactions_by_epic(dealing_platform)
        activities = dealing_platform.account.activities history_options
        transactions = dealing_platform.account.transactions history_options.merge(type: :all_deal)

        transactions.group_by do |transaction|
          activities.detect do |activity|
            Regexp.new("^Position(\/s| partially) closed:.*#{transaction.reference}").match activity.description
          end.epic
        end
      end

      def print_summary(performances)
        profit_loss = performances.map { |h| h[:profit_loss] }.inject(:+)
        currency = performances.first[:transactions].first.currency

        puts <<-END

Note: this table only shows the profit/loss made from dealing, it does not include interest payments, dividends, or
      other adjustments that may have occurred over this period.

Total: #{Format.currency(profit_loss, currency).colorize(profit_loss < 0 ? :red : :green)}
END
      end
    end
  end
end
