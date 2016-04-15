module IGMarkets
  module CLI
    # Implements the `ig_markets account` command.
    class Main
      desc 'account', 'Prints account overview and balances'

      def account
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.account.all.each do |account|
            Output.print_account account
            Output.print_account_balance account
          end
        end
      end
    end
  end
end
