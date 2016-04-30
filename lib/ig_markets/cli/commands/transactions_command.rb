module IGMarkets
  module CLI
    # Implements the `ig_markets transactions` command.
    class Main
      desc 'transactions', 'Prints account transactions'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account transactions for'
      option :from, desc: 'The start date to print account transactions from, format: yyyy-mm-dd'
      option :instrument, desc: 'Regex for filtering transactions based on their instrument'
      option :interest, type: :boolean, default: true, desc: 'Whether to show interest deposits and withdrawals'

      def transactions
        self.class.begin_session(options) do |_dealing_platform|
          transactions = gather_transactions

          table = TransactionsTable.new transactions

          puts table

          if transactions.any?
            puts ''
            print_transaction_totals transactions
          end
        end
      end

      private

      def gather_transactions
        regex = Regexp.new options.fetch('instrument', '')

        gather_account_history(:transactions).sort_by(&:date_utc).select do |transaction|
          regex.match(transaction.instrument_name) && (options[:interest] || !transaction.interest?)
        end
      end

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

        if options[:interest]
          puts "Interest: #{totals.map { |currency, value| Format.currency value[:interest], currency }.join ', '}"
        end

        puts "Profit/loss: #{totals.map { |currency, value| Format.currency value[:delta], currency }.join ', '}"
      end
    end
  end
end
