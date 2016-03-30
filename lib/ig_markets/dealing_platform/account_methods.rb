module IGMarkets
  class DealingPlatform
    # Helper class that provides methods for interacting with the logged in account.
    class AccountMethods
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all accounts associated with the current IG Markets login.
      #
      # @return [Array<Account>]
      def all
        @dealing_platform.gather 'accounts', :accounts, Account
      end

      # Returns all account activities that occurred in the specified date range.
      #
      # @param [Date] from_date The start date of the desired date range.
      # @param [Date] to_date The end date of the desired date range.
      #
      # @return [Array<AccountActivity>]
      def activities_in_date_range(from_date, to_date = Date.today)
        from_date = format_date from_date
        to_date = format_date to_date

        @dealing_platform.gather "history/activity/#{from_date}/#{to_date}", :activities, AccountActivity
      end

      # Returns all account activities that occurred in the most recent specified number of seconds.
      #
      # @param [Integer] seconds The number of seconds to return recent activities for.
      #
      # @return [Array<AccountActivity>]
      def recent_activities(seconds)
        @dealing_platform.gather "history/activity/#{seconds.to_i * 1000}", :activities, AccountActivity
      end

      # Returns all transactions that occurred in the specified date range.
      #
      # @param [Date] from_date The start date of the desired date range.
      # @param [Date] to_date  The end date of the desired date range.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<AccountTransaction>]
      def transactions_in_date_range(from_date, to_date = Date.today, transaction_type = :all)
        Validate.transaction_type! transaction_type

        from_date = format_date from_date
        to_date = format_date to_date

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}"

        @dealing_platform.gather url, :transactions, AccountTransaction
      end

      # Returns all transactions that occurred in the last specified number of seconds.
      #
      # @param [Integer] seconds The number of seconds to return recent transactions for.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<AccountTransaction>]
      def recent_transactions(seconds, transaction_type = :all)
        Validate.transaction_type! transaction_type

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{seconds.to_i * 1000}"

        @dealing_platform.gather url, :transactions, AccountTransaction
      end

      private

      def format_date(date)
        date.strftime '%d-%m-%Y'
      end
    end
  end
end
