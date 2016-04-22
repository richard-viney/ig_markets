module IGMarkets
  module CLI
    # Implements the `ig_markets transactions` command.
    class Main
      desc 'transactions', 'Prints account transactions'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account transactions for'
      option :start_date, desc: 'The start date to print account transactions from, format: yyyy-mm-dd'
      option :instrument, desc: 'Regex for filtering transactions based on their instrument'

      def transactions
        regex = Regexp.new(options['instrument'] || '')

        self.class.begin_session(options) do |_dealing_platform|
          transactions = gather_account_history(:transactions).sort_by(&:date).select do |transaction|
            regex.match transaction.instrument_name
          end

          table = TransactionsTable.new transactions

          puts table

          print_transaction_totals transactions
        end
      end

      private

      def transaction_totals(transactions)
        transactions.each_with_object({}) do |transaction, hash|
          profit_loss = transaction.profit_and_loss_amount

          currency = (hash[transaction.currency] ||= Hash.new(0))

          currency[:delta] += profit_loss
          currency[:interest] += profit_loss if transaction.interest?
        end
      end

      def print_transaction_totals(transactions)
        totals = transaction_totals transactions

        return if totals.empty?

        puts <<-END

Interest: #{totals.map { |currency, value| Format.currency value[:interest], currency }.join ', '}
Profit/loss: #{totals.map { |currency, value| Format.currency value[:delta], currency }.join ', '}
END
      end
    end
  end
end
