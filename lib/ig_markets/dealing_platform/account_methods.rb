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
        result = @dealing_platform.session.get('accounts').fetch :accounts

        @dealing_platform.instantiate_models Account, result
      end

      # Returns all account activities that occurred in the specified date range.
      #
      # @param [Date] from_date The start date of the desired date range.
      # @param [Date] to_date The end date of the desired date range.
      #
      # @return [Array<Activity>]
      def activities_in_date_range(from_date, to_date)
        from_date = format_date from_date
        to_date = format_date to_date

        result = @dealing_platform.session.get("history/activity/#{from_date}/#{to_date}").fetch :activities

        @dealing_platform.instantiate_models Activity, result
      end

      # Returns all account activities that occurred in the most recent specified number of days.
      #
      # @param [Fixnum, Float] days The number of days to return recent activities for.
      #
      # @return [Array<Activity>]
      def recent_activities(days)
        result = @dealing_platform.session.get("history/activity/#{milliseconds(days)}").fetch :activities

        @dealing_platform.instantiate_models Activity, result
      end

      # Returns all transactions that occurred in the specified date range.
      #
      # @param [Date] from_date The start date of the desired date range.
      # @param [Date] to_date The end date of the desired date range.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<Transaction>]
      def transactions_in_date_range(from_date, to_date, transaction_type = :all)
        validate_transaction_type transaction_type

        from_date = format_date from_date
        to_date = format_date to_date

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}"
        result = @dealing_platform.session.get(url).fetch :transactions

        @dealing_platform.instantiate_models Transaction, result
      end

      # Returns all transactions that occurred in the last specified number of days.
      #
      # @param [Fixnum, Float] days The number of days to return recent transactions for.
      # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
      #
      # @return [Array<Transaction>]
      def recent_transactions(days, transaction_type = :all)
        validate_transaction_type transaction_type

        url = "history/transactions/#{transaction_type.to_s.upcase}/#{milliseconds(days)}"
        result = @dealing_platform.session.get(url).fetch :transactions

        @dealing_platform.instantiate_models Transaction, result
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

      # Converts a number of days into a number of milliseconds.
      #
      # @param [Fixnum, Float] days The number of days.
      #
      # @return [Fixnum]
      def milliseconds(days)
        (days.to_f * 24 * 60 * 60 * 1000).to_i
      end
    end
  end
end
