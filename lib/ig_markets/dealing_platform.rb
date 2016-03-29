# rubocop:disable Metrics/ClassLength

# This module contains all the code for the IG Markets gem. See the {DealingPlatform} class to get started.
module IGMarkets
  # This is the primary class for interacting with the IG Markets API. Sign in using {#sign_in}, then call other
  # instance methods are required to perform the actions you are interested in. See `README.md` for a usage example.
  #
  # If any errors occur while executing requests to the IG Markets API then {RequestFailedError} will be raised.
  class DealingPlatform
    attr_reader :session

    def initialize
      @session = Session.new
    end

    # Signs in to the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param [String] username The account username.
    # @param [String] password The account password.
    # @param [String] api_key The account API key.
    # @param [:production, :demo] platform The platform to use.
    #
    # @return [void]
    def sign_in(username, password, api_key, platform)
      session.username = username
      session.password = password
      session.api_key = api_key
      session.platform = platform

      session.sign_in
    end

    # Signs out of the IG Markets Dealing Platform, ending any current session.
    #
    # @return [void]
    def sign_out
      session.sign_out
    end

    # Returns all accounts.
    #
    # @return [Array<Account>]
    def accounts
      gather 'accounts', :accounts, Account
    end

    # Returns all account activities that occurred in the specified date range.
    #
    # @param [Date] from_date The start date of the desired date range.
    # @param [Date] to_date  The end date of the desired date range.
    #
    # @return [Array<AccountActivity>]
    def activities_in_date_range(from_date, to_date = Date.today)
      from_date = format_activity_date(from_date)
      to_date = format_activity_date(to_date)

      gather "history/activity/#{from_date}/#{to_date}", :activities, AccountActivity
    end

    # Returns all account activities that occurred in the last specified number of milliseconds.
    #
    # @param [Integer] milliseconds The number of milliseconds to return recent activities for.
    #
    # @return [Array<AccountActivity>]
    def activities_in_recent_period(milliseconds)
      gather "history/activity/#{milliseconds.to_i}", :activities, AccountActivity
    end

    # Returns all transactions that occurred in the specified date range.
    #
    # @param [Date] from_date The start date of the desired date range.
    # @param [Date] to_date  The end date of the desired date range.
    # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
    #
    # @return [Array<Transaction>]
    def transactions_in_date_range(from_date, to_date = Date.today, transaction_type = :all)
      Validate.transaction_type! transaction_type

      from_date = format_activity_date from_date
      to_date = format_activity_date to_date

      gather "history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}", :transactions, Transaction
    end

    # Returns all transactions that occurred in the last specified number of milliseconds.
    #
    # @param [Integer] milliseconds The number of milliseconds to return recent transactions for.
    # @param [:all, :all_deal, :deposit, :withdrawal] transaction_type The type of transactions to return.
    #
    # @return [Array<Transaction>]
    def transactions_in_recent_period(milliseconds, transaction_type = :all)
      Validate.transaction_type! transaction_type

      gather "history/transactions/#{transaction_type.to_s.upcase}/#{milliseconds}", :transactions, Transaction
    end

    # Returns a full deal confirmation for the specified deal reference.
    #
    # @return [DealConfirmation]
    def deal_confirmation(deal_reference)
      result = session.get "confirms/#{deal_reference}", API_VERSION_1
      DealConfirmation.new result
    end

    # Returns all open positions.
    #
    # @return [Array<Position>]
    def positions
      session.get('positions', API_VERSION_2).fetch(:positions).map do |attributes|
        Position.new attributes_with_market(attributes, :position, :market)
      end
    end

    # Returns position information for the specified deal ID.
    #
    # @return [Position]
    def position(deal_id)
      attributes = session.get "positions/#{deal_id}", API_VERSION_2

      Position.new attributes_with_market(attributes, :position, :market)
    end

    # Returns all current sprint market positions.
    #
    # @return [Array<SprintMarketPosition>] an array of current sprint market positions.
    def sprint_market_positions
      gather 'positions/sprintmarkets', :sprint_market_positions, SprintMarketPosition
    end

    # Returns all working orders.
    #
    # @return [Array<WorkingOrder>]
    def working_orders
      session.get('workingorders', API_VERSION_2).fetch(:working_orders).map do |attributes|
        WorkingOrder.new attributes_with_market(attributes, :working_order_data, :market_data)
      end
    end

    # Returns details on the market hierarchy directly under a single node.
    #
    # @param [String] node_id The ID of the node to return the market hierarchy for. If this is `nil` then details on
    #                         the root node of the market hierarchy will be returned.
    #
    # @return [Hash] A hash containing two keys: `:markets` which is an array of {Market} instances, and `:nodes` which
    #                is an array of {MarketHierarchyNode} instances.
    def market_hierarchy(node_id = nil)
      url = ['marketnavigation', node_id].compact.join '/'

      result = session.get(url, API_VERSION_1)

      {
        markets: Market.from(result.fetch(:markets) || []),
        nodes: MarketHierarchyNode.from(result.fetch(:nodes) || [])
      }
    end

    # Returns market details for a set of markets.
    #
    # @param [Array<String>] epics The EPICs of the markets to return the current status of.
    #
    # @return [Array<Hash>] An array of hashes, one for each EPIC passed to this method. Each hash contains three keys:
    #                       `:dealing_rules` which is a Hash containing a set of named {DealingRule} instances,
    #                       `:instrument` which is an {Instrument}, and `:snapshot` which is a {MarketSnapshot}.
    def markets(*epics)
      raise ArgumentError, 'at least one epic must be specified' if epics.empty?

      Validate.epic! epics

      result = session.get "markets?epics=#{epics.join(',')}", API_VERSION_1

      result.fetch(:market_details).map do |attributes|
        {
          dealing_rules: parse_dealing_rules(attributes.fetch(:dealing_rules)),
          instrument: Instrument.new(attributes.fetch(:instrument)),
          snapshot: MarketSnapshot.new(attributes.fetch(:snapshot))
        }
      end
    end

    # Searches markets based on a query string.
    #
    # @param [String] search_term The search term to use to search the markets.
    #
    # @return [Array<Market>] An array of the markets that matched the search term.
    def market_search(search_term)
      gather "markets?searchTerm=#{search_term}", :markets, Market
    end

    # Returns recent historical prices for a market at a specified resolution.
    #
    # @param [String] epic The EPIC of the market to return historical prices for.
    # @param [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3,
    #         :hour_4, :day, :week, :month] resolution The resolution of the historical prices to return.
    # @param [Fixnum] num_points The number of historical prices to return.
    #
    # @return [Hash] A hash containing three keys: `:allowance` which is a {HistoricalPriceDataAllowance},
    #                `:instrument_type` which is a `Symbol`, and `:prices` which is an
    #                `Array<`{HistoricalPriceSnapshot}`>`.
    def recent_prices(epic, resolution, num_points)
      Validate.epic! epic
      Validate.historical_price_resolution! resolution

      gather_prices "prices/#{epic}/#{resolution.to_s.upcase}/#{num_points.to_i}"
    end

    # Returns historical prices for a market at a specified resolution over a specified time period.
    #
    # @param [String] epic The EPIC of the market to returns historical prices for.
    # @param [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3,
    #         :hour_4, :day, :week, :month] resolution The resolution of the historical prices to return.
    # @param [DateTime] start_date_time
    # @param [DateTime] end_date_time
    #
    # @return [Hash] A hash containing three keys: `:allowance` which is a {HistoricalPriceDataAllowance},
    #                `:instrument_type` which is a `Symbol`, and `:prices` which is an
    #                `Array<`{HistoricalPriceSnapshot}`>`.
    def prices_in_date_range(epic, resolution, start_date_time, end_date_time)
      Validate.epic! epic
      Validate.historical_price_resolution! resolution

      start_date_time = format_historical_price_date_time start_date_time
      end_date_time = format_historical_price_date_time end_date_time

      gather_prices "prices/#{epic}/#{resolution.to_s.upcase}/#{start_date_time}/#{end_date_time}"
    end

    # Returns all watchlists.
    #
    # @return [Array<Watchlist>]
    def watchlists
      gather 'watchlists', :watchlists, Watchlist
    end

    # Returns the markets for a watchlist.
    #
    # @param [String] watchlist_id The ID of the watchlist to return the markets for.
    #
    # @return [Array<Market>]
    def watchlist_markets(watchlist_id)
      gather "watchlists/#{watchlist_id}", :markets, Market
    end

    # Creates a new watchlist with a name and an initial set of markets.
    #
    # @return [String] The ID of the new watchlist.
    def watchlist_create(name, epics = [])
      payload = { name: name, epics: Array(epics) }

      session.post 'watchlists', payload, API_VERSION_1
    end

    # Deletes a watchlist.
    #
    # @param [String] watchlist_id The ID of the watchlist to delete.
    #
    # @return [void]
    def watchlist_delete(watchlist_id)
      session.delete "watchlists/#{watchlist_id}", nil, API_VERSION_1
    end

    # Adds a market to a watchlist.
    #
    # @param [String] watchlist_id The ID of the watchlist to add a market to.
    # @param [String] epic The EPIC of the market to add to the watchlist.
    #
    # @return [void]
    def watchlist_add_market(watchlist_id, epic)
      payload = { epic: epic }

      session.put "watchlists/#{watchlist_id}", payload, API_VERSION_1
    end

    # Removes a market from a watchlist.
    #
    # @param [String] watchlist_id The ID of the watchlist to remove a market from.
    # @param [String] epic The EPIC of the market to remove from the watchlist.
    #
    # @return [void]
    def watchlist_remove_market(watchlist_id, epic)
      session.delete "watchlists/#{watchlist_id}/#{epic}", nil, API_VERSION_1
    end

    # Returns the client sentiment for a market.
    #
    # @param [String] market_id The ID of the market to return client sentiment for.
    #
    # @return [ClientSentiment]
    def client_sentiment(market_id)
      result = session.get "clientsentiment/#{market_id}", API_VERSION_1
      ClientSentiment.new result
    end

    # Returns an array of client sentiments related to a market.
    #
    # @param [String] market_id The ID of the market to return related client sentiments for.
    #
    # @return [Array<ClientSentiment>]
    def client_sentiment_related(market_id)
      gather "clientsentiment/related/#{market_id}", :client_sentiments, ClientSentiment
    end

    # Returns details on the IG Markets application for this account.
    #
    # @return [Application]
    def applications
      result = session.get 'operations/application', API_VERSION_1

      Application.from result
    end

    private

    def gather(url, collection, klass, api_version = API_VERSION_1)
      klass.from session.get(url, api_version).fetch(collection)
    end

    def format_activity_date(date)
      date.strftime '%d-%m-%Y'
    end

    def attributes_with_market(attributes, base_attribute, market_attribute)
      attributes.fetch(base_attribute).merge(market: attributes.fetch(market_attribute))
    end

    def parse_dealing_rules(rules)
      {
        market_order_preference: rules.fetch(:market_order_preference),
        trailing_stops_preference: rules.fetch(:trailing_stops_preference),
        max_stop_or_limit_distance: DealingRule.new(rules.fetch(:max_stop_or_limit_distance)),
        min_controlled_risk_stop_distance: DealingRule.new(rules.fetch(:min_controlled_risk_stop_distance)),
        min_deal_size: DealingRule.new(rules.fetch(:min_deal_size)),
        min_normal_stop_or_limit_distance: DealingRule.new(rules.fetch(:min_normal_stop_or_limit_distance)),
        min_step_distance: DealingRule.new(rules.fetch(:min_step_distance))
      }
    end

    def format_historical_price_date_time(datetime)
      datetime.strftime '%Y-%m-%d %H:%M:%S'
    end

    def gather_prices(url)
      result = session.get url, API_VERSION_2

      {
        allowance: HistoricalPriceDataAllowance.new(result.fetch(:allowance)),
        instrument_type: result.fetch(:instrument_type).downcase.to_sym,
        prices: HistoricalPriceSnapshot.from(result.fetch(:prices))
      }
    end
  end
end
