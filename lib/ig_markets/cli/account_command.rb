module IGMarkets
  module CLI
    # Implements the `ig_markets account` command.
    class Main
      desc 'account', 'Prints account overview and balances'

      def account
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.account.all.each do |account|
            print_account account
            print_account_balance account
          end
        end
      end

      private

      def print_account(account)
        puts <<-END
Account '#{account.account_name}':
  ID:           #{account.account_id}
  Type:         #{account.account_type.to_s.upcase}
  Currency:     #{account.currency}
  Status:       #{account.status.to_s.upcase}
END
      end

      def print_account_balance(account)
        {
          available:   'Available:  ',
          balance:     'Balance:    ',
          deposit:     'Margin:     ',
          profit_loss: 'Profit/loss:'
        }.each do |attribute, display_name|
          puts "  #{display_name}  #{Format.currency account.balance.send(attribute), account.currency}"
        end
      end
    end
  end
end
