module IGMarkets
  module CLI
    # Implements the `ig_markets transactions` command.
    class Main
      desc 'transactions', 'Prints recent transactions'

      option :days, default: 3, type: :numeric, desc: 'The number of days to print recent transactions for'

      def transactions
        self.class.begin_session(options) do |dealing_platform|
          transactions = dealing_platform.account.recent_transactions(seconds).sort_by(&:date)

          transactions.each do |transaction|
            print_transaction transaction
          end

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

      def print_transaction(transaction)
        puts <<-END
#{transaction.reference}: #{transaction.date.strftime '%Y-%m-%d'}, \
#{transaction.formatted_transaction_type}, \
#{"#{transaction.size} of " if transaction.size}\
#{transaction.instrument_name}, \
profit/loss: #{Format.currency transaction.profit_and_loss_amount, transaction.currency}
END
      end

      def print_transaction_totals(transactions)
        transaction_totals(transactions).each do |currency, value|
          puts <<-END

Totals for currency '#{currency}':
  Interest: #{Format.currency value[:interest], currency}
  Profit/loss: #{Format.currency value[:delta], currency}
END
        end
      end
    end
  end
end
