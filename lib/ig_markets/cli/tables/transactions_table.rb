module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::AccountTransaction} instances in a table.
    class TransactionsTable < Table
      private

      def default_title
        'Transactions'
      end

      def headings
        ['Date', 'Reference', 'Type', 'Size', 'Instrument', 'Profit/loss']
      end

      def row(transaction)
        [
          transaction.date.strftime('%F'),
          transaction.reference,
          formatted_type(transaction.transaction_type),
          transaction.size,
          transaction.instrument_name,
          Format.currency(transaction.profit_and_loss_amount, transaction.currency)
        ]
      end

      def formatted_type(type)
        { deal: 'Deal', depo: 'Deposit', dividend: 'Dividend', exchange: 'Exchange', with: 'Withdrawal' }.fetch type
      end
    end
  end
end
