module IGMarkets
  module CLI
    # Implements the `ig_markets transactions` command.
    class Main
      desc 'transactions', 'Prints account transactions'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account transactions for'
      option :from, desc: 'The start date to print account transactions from, format: yyyy-mm-dd'
      option :instrument, desc: 'Regex for filtering transactions based on their instrument'
      option :interest, type: :boolean, default: true, desc: 'Whether to show interest deposits and withdrawals'
      option :sort_by, enum: %w(date instrument profit-loss type), default: 'date', desc: 'The attribute to sort ' \
                                                                                          'transactions by'

      def transactions
        self.class.begin_session(options) do |dealing_platform|
          transactions = gather_transactions dealing_platform

          table = TransactionsTable.new transactions

          puts table

          if transactions.any?
            puts ''
            print_transaction_totals transactions
          end
        end
      end

      private

      def gather_transactions(dealing_platform)
        @instrument_regex = Regexp.new options.fetch('instrument', ''), Regexp::IGNORECASE

        result = gather_account_history(:transactions, dealing_platform).select do |transaction|
          transaction_filter transaction
        end

        result.sort_by do |transaction|
          [transaction.send(transaction_sort_attribute), transaction.date_utc]
        end
      end

      def transaction_filter(transaction)
        return false if !options[:interest] && transaction.interest?

        @instrument_regex.match transaction.instrument_name
      end

      def transaction_sort_attribute
        {
          'date' => :date_utc,
          'instrument' => :instrument_name,
          'profit-loss' => :profit_and_loss_amount,
          'type' => :transaction_type
        }.fetch options[:sort_by]
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
