module IGMarkets
  module CLI
    # Implements the `ig_markets account` command.
    class Main
      desc 'account', 'Prints account overview and balances'

      def account
        self.class.begin_session(options) do |dealing_platform|
          accounts = dealing_platform.account.all

          table = Tables::AccountsTable.new accounts

          puts table
        end
      end
    end
  end
end
