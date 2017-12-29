module IGMarkets
  class DealingPlatform
    # Provides methods for working with the logged in account. Returned by {DealingPlatform#account}.
    class AccountMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = WeakRef.new dealing_platform
      end

      # Returns all accounts associated with the current IG Markets login.
      #
      # @return [Array<Account>]
      def all
        result = @dealing_platform.session.get('accounts').fetch :accounts

        @dealing_platform.instantiate_models Account, result
      end

      # Returns activities for this account in the specified time range.
      #
      # @param [Hash] options The options hash.
      # @option options [Time] :from The start of the period to return activities for. Required.
      # @option options [Time] :to The end of the period to return activities for. Defaults to `Time.now`.
      #
      # @return [Array<Activity>]
      def activities(options)
        activities_request build_url_parameters(options).merge(detailed: true)
      end

      # Returns transactions for this account in the specified time range.
      #
      # @param [Hash] options The options hash.
      # @option options [:all, :all_deal, :deposit, :withdrawal] :type The type of transactions to return. Defaults to
      #                 `:all`.
      # @option options [Time] :from The start of the period to return transactions for. Required.
      # @option options [Time] :to The end of the period to return transactions for. Defaults to `Time.now`.
      #
      # @return [Array<Transaction>]
      def transactions(options)
        options[:type] ||= :all

        unless %i[all all_deal deposit withdrawal].include? options[:type]
          raise ArgumentError, "invalid transaction type: #{options[:type]}"
        end

        tranaactions_request build_url_parameters(options)
      end

      private

      # Parses and formats options shared by {#activities} and {#transactions} into a set of URL parameters.
      def build_url_parameters(options)
        options[:to] ||= Time.now

        options[:from] = options.fetch(:from).utc.strftime('%FT%T')
        options[:to] = options.fetch(:to).utc.strftime('%FT%T')

        options[:pageSize] = 500
        options[:type] = options[:type].to_s.upcase if options.key? :type

        options
      end

      # Performs repeated requests to the IG Markets API to retrieve all pages of activities returned by the given set
      # of URL parameters.
      def activities_request(url_parameters)
        activities = []

        url = 'history/activity'

        while url
          request_result = history_request url: url, api_version: API_V3, url_parameters: url_parameters
          activities += @dealing_platform.instantiate_models(Activity, request_result.fetch(:activities))

          url = request_result.fetch(:metadata).fetch(:paging).fetch(:next)
          url_parameters = {}
        end

        activities
      end

      # Performs repeated requests to the IG Markets API to retrieve all pages of transactions returned by the given set
      # of URL parameters.
      def tranaactions_request(url_parameters)
        transactions = []

        page_number = 1

        loop do
          request_result = history_request url: 'history/transactions', api_version: API_V2,
                                           url_parameters: url_parameters.merge(pageNumber: page_number)

          transactions += @dealing_platform.instantiate_models Transaction, request_result.fetch(:transactions)

          break if page_number == request_result.fetch(:metadata).fetch(:page_data).fetch(:total_pages)

          page_number += 1
        end

        transactions
      end

      def history_request(options)
        params = URI.encode_www_form options.fetch(:url_parameters)

        url = options[:url]
        url += "?#{params}" unless params.empty?

        @dealing_platform.session.get url, options.fetch(:api_version)
      end
    end
  end
end
