module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::Account} instances in a table.
    class AccountsTable < Table
      private

      def default_title
        'Accounts'
      end

      def headings
        ['Name', 'ID', 'Type', 'Currency', 'Status', 'Available', 'Balance', 'Margin', 'Profit/loss']
      end

      def right_aligned_columns
        [5, 6, 7, 8]
      end

      def row(account)
        type = { cfd: 'CFD', physical: 'Physical', spreadbet: 'Spreadbet' }.fetch account.account_type
        status = { disabled: 'Disabled', enabled: 'Enabled', suspended_from_dealing: 'Suspended' }.fetch account.status

        [account.account_name, account.account_id, type, account.currency, status] +
          [:available, :balance, :deposit, :profit_loss].map do |attribute|
            Format.currency account.balance.send(attribute), account.currency
          end
      end
    end
  end
end
