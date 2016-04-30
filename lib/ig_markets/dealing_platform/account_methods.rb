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

      # Returns activities for this account, either the most recent activities by specifying the `:days` option, or
      # those from a date range by specifying the `:from` and `:to` options.
      #
      # @param [Hash] options The options hash.
      # @option options [Float] :days The number of recent days to return activities for. If this is specified then the
      #                 `:from` and `:to` options must not be specified.
      # @option options [Date] :from The start of the period to return activities for.
      # @option options [Date] :to The end of the period to return activities for.
      #
      # @return [Array<Activity>]
      def activities(options)
        parse_history_options options

        result = history_request('history/activity', options)

        @dealing_platform.instantiate_models Activity, result.fetch(:activities)
      end

      # Returns transactions for this account, either the most recent transactions by specifying the `:days` option, or
      # those from a date range by specifying the `:from` and `:to` options.
      #
      # @param [Hash] options The options hash.
      # @option options [:all, :all_deal, :deposit, :withdrawal] :type The type of transactions to return. Defaults to
      #                 `:all`.
      # @option options [Float] :days The number of recent days to return transactions for. If this is specified then
      #                 the `:from` and `:to` options must not be specified.
      # @option options [Date] :from The start of the period to return transactions for.
      # @option options [Date] :to The end of the period to return transactions for.
      #
      # @return [Array<Activity>]
      def transactions(options)
        options[:type] ||= :all

        parse_history_options options

        result = history_request('history/transactions', options)

        @dealing_platform.instantiate_models Transaction, result.fetch(:transactions)
      end

      private

      # Sends a GET request to the specified URL with the passed options and returns the response.
      #
      # @param [String] url The base URL.
      # @param [Hash] options The options to put with the URL.
      #
      # @return [Hash]
      def history_request(url, options)
        url = "#{url}?#{options.map { |key, value| "#{key}=#{value.to_s.upcase}" }.join '&'}"

        @dealing_platform.session.get url, API_V2
      end

      # Parses and formats the history options shared by {#activities} and {#transactions}.
      #
      # @param [Hash] options
      def parse_history_options(options)
        options[:maxSpanSeconds] = (options.delete(:days).to_f * 24 * 60 * 60).to_i if options.key? :days
        options[:from] = options[:from].strftime('%F') if options.key? :from
        options[:to] = options[:to].strftime('%F') if options.key? :to
      end
    end
  end
end
