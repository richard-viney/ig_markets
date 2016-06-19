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

      # Returns activities for this account in the specified date range.
      #
      # @param [Hash] options The options hash.
      # @option options [Date] :from The start of the period to return activities for. Required.
      # @option options [Date] :to The end of the period to return activities for. Defaults to today.
      #
      # @return [Array<Activity>]
      def activities(options)
        history_request_complete url: 'history/activity', url_parameters: prepare_history_options(options),
                                 collection_name: :activities, model_class: Activity, date_attribute: :date
      end

      # Returns transactions for this account in the specified date range.
      #
      # @param [Hash] options The options hash.
      # @option options [:all, :all_deal, :deposit, :withdrawal] :type The type of transactions to return. Defaults to
      #                 `:all`.
      # @option options [Date] :from The start of the period to return transactions for. Required.
      # @option options [Date] :to The end of the period to return transactions for. Defaults to today.
      #
      # @return [Array<Transaction>]
      def transactions(options)
        options[:type] ||= :all

        history_request_complete url: 'history/transactions', url_parameters: prepare_history_options(options),
                                 collection_name: :transactions, model_class: Transaction, date_attribute: :date_utc
      end

      private

      # The maximum number of results the IG Markets API will return in one request.
      MAXIMUM_PAGE_SIZE = 500

      # Retrieves historical data for this account (either activities or transactions) in the specified date range. This
      # methods sends a single GET request with the passed URL parameters and returns the response. The maximum number
      # of items this method can return is capped at 500 {MAXIMUM_PAGE_SIZE}.
      def history_request(options)
        url = "#{options[:url]}?#{options[:url_parameters].map { |key, value| "#{key}=#{value.to_s.upcase}" }.join '&'}"

        get_result = @dealing_platform.session.get url, API_V2

        @dealing_platform.instantiate_models options[:model_class], get_result.fetch(options[:collection_name])
      end

      # This method is the same as {#history_request} except it will send as many GET requests as are needed in order
      # to circumvent the maximum number of results that can be returned per request.
      def history_request_complete(options)
        models = []

        loop do
          request_result = history_request options
          models += request_result

          break if request_result.size < MAXIMUM_PAGE_SIZE

          # Update the :to parameter so the next GET request returns older results
          options[:url_parameters][:to] = request_result.last.send(options[:date_attribute]).utc.to_date + 1
        end

        models.uniq
      end

      # Parses and formats the history options shared by {#activities} and {#transactions}.
      def prepare_history_options(options)
        options[:to] ||= Date.today + 1

        options[:from] = options.fetch(:from).strftime('%F')
        options[:to] = options.fetch(:to).strftime('%F')

        options[:pageSize] = MAXIMUM_PAGE_SIZE

        options
      end
    end
  end
end
