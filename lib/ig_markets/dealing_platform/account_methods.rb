module IGMarkets
  class DealingPlatform
    # Provides methods for working with the logged in account. Returned by {DealingPlatform#account}.
    class AccountMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
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
      def activities_in_date_range(from_date, to_date)
        from_date = format_date from_date
        to_date = format_date to_date

        @dealing_platform.gather "history/activity/#{from_date}/#{to_date}", :activities, AccountActivity
      end

      # Returns all account activities that occurred in the most recent specified number of seconds.
      #
      # @param [Integer, Float] seconds The number of seconds to return recent activities for.
      #
      # @return [Array<AccountActivity>]
      def recent_activities(seconds)
        @dealing_platform.gather "history/activity/#{(seconds * 1000.0).to_i}", :activities, AccountActivity
      end

      # Returns all transactions that occurred in the specified date range.
      #
      # @param [Date] from_date The start date of the desired date range.
      # @param [Date] to_date The end date of the desired date range.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<AccountTransaction>]
      def transactions_in_date_range(from_date, to_date, transaction_type = :all)
        validate_transaction_type transaction_type

        from_date = format_date from_date
        to_date = format_date to_date

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}"

        @dealing_platform.gather url, :transactions, AccountTransaction
      end

      # Returns all transactions that occurred in the last specified number of seconds.
      #
      # @param [Integer, Float] seconds The number of seconds to return recent transactions for.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<AccountTransaction>]
      def recent_transactions(seconds, transaction_type = :all)
        validate_transaction_type transaction_type

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{(seconds * 1000.0).to_i}"

        @dealing_platform.gather url, :transactions, AccountTransaction
      end

      private

      # Validates whether the passed argument is a valid transaction type.
      #
      # @param [Symbol] type The candidate transaction type to validate.
      def validate_transaction_type(type)
        raise ArgumentError, 'transaction type is invalid' unless [:all, :all_deal, :deposit, :withdrawal].include? type
      end

      # Formats the passed `Date` as a string in the manner needed for building IG Markets URLs.
      #
      # @param [Date] date The date to format.
      #
      # @return [String]
      def format_date(date)
        date.strftime '%d-%m-%Y'
      end
    end
  end
end
