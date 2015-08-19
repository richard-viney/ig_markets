module IGMarkets
  module SessionMethods
    # Signs in to the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param username [String] the account username
    # @param password [String] the account password
    # @param api_key [String] the account API key
    # @param platform [:production, :demo] the platform to use
    def sign_in(username, password, api_key, platform = :demo)
      session.username = username
      session.password = password
      session.api_key = api_key
      session.platform = platform

      session.sign_in
    end

    # Signs out of the IG Markets Dealing Platform
    def sign_out
      session.sign_out
    end
  end

  module AccountMethods
    def accounts
      gather 'accounts', :accounts, Account
    end

    def activities_in_date_range(from_date, to_date = Date.today)
      from_date = format_activity_date(from_date)
      to_date = format_activity_date(to_date)

      gather "history/activity/#{from_date}/#{to_date}", :activities, AccountActivity
    end

    def activities_in_recent_period(milliseconds)
      gather "history/activity/#{milliseconds.to_i}", :activities, AccountActivity
    end

    def transactions_in_date_range(from_date, to_date = Date.today, transaction_type = :all)
      Validate.transaction_type! transaction_type

      from_date = format_activity_date from_date
      to_date = format_activity_date to_date

      gather "history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}", :transactions, Transaction
    end

    def transactions_in_recent_period(milliseconds, transaction_type = :all)
      Validate.transaction_type! transaction_type

      gather "history/transactions/#{transaction_type.to_s.upcase}/#{milliseconds}", :transactions, Transaction
    end

    private

    def format_activity_date(d)
      d.strftime '%d-%m-%Y'
    end
  end

  module DealingMethods
    def positions
      session.get('positions', API_VERSION_2).fetch(:positions).map do |attributes|
        Position.new attributes_with_market(attributes, :position, :market)
      end
    end

    def position(deal_id)
      attributes = session.get "positions/#{deal_id}", API_VERSION_2

      Position.new attributes_with_market(attributes, :position, :market)
    end

    def sprint_market_positions
      gather 'positions/sprintmarkets', :sprint_market_positions, SprintMarketPosition
    end

    def working_orders
      session.get('workingorders', API_VERSION_2).fetch(:working_orders).map do |attributes|
        WorkingOrder.new attributes_with_market(attributes, :working_order_data, :market_data)
      end
    end

    private

    def attributes_with_market(attributes, base_attribute, market_attribute)
      attributes.fetch(base_attribute).merge(market: attributes.fetch(market_attribute))
    end
  end

  module MarketMethods
    def market_hierarchy(node_id = nil)
      url = ['marketnavigation', node_id].compact.join '/'

      result = session.get(url, API_VERSION_1)

      {
        markets: (result.fetch(:markets) || []).map { |attributes| Market.new attributes },
        nodes:   (result.fetch(:nodes) || []).map   { |attributes| MarketHierarchyNode.new attributes }
      }
    end

    def market(epic)
      markets(epic)[0]
    end

    def markets(*epics)
      fail ArgumentError, 'at least one epic must be specified' if epics.empty?

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

    def market_search(search_term)
      gather "markets?searchTerm=#{search_term}", :markets, Market
    end

    def prices(epic, resolution, num_points)
      Validate.epic! epic
      Validate.historical_price_resolution! resolution

      gather_prices "prices/#{epic}/#{resolution.to_s.upcase}/#{num_points.to_i}"
    end

    def prices_in_date_range(epic, resolution, start_date_time, end_date_time = DateTime.now)
      Validate.epic! epic
      Validate.historical_price_resolution! resolution

      start_date_time = format_historical_price_date_time start_date_time
      end_date_time = format_historical_price_date_time end_date_time

      gather_prices "prices/#{epic}/#{resolution.to_s.upcase}/#{start_date_time}/#{end_date_time}"
    end

    private

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

    def format_historical_price_date_time(dt)
      dt.strftime '%Y-%m-%d %H:%M:%S'
    end

    def gather_prices(url)
      result = session.get url, API_VERSION_2

      {
        allowance: HistoricalPriceDataAllowance.new(result.fetch(:allowance)),
        instrument_type: result.fetch(:instrument_type),
        prices: result.fetch(:prices).map { |attributes| HistoricalPriceSnapshot.new attributes }
      }
    end
  end

  module WatchlistMethods
    def watchlists
      gather 'watchlists', :watchlists, Watchlist
    end

    def watchlist_markets(watchlist_id)
      gather "watchlists/#{watchlist_id}", :markets, Market
    end
  end

  module ClientSentimentMethods
    def client_sentiment(market_id)
      result = session.get "clientsentiment/#{market_id}", API_VERSION_1
      ClientSentiment.new result
    end

    def client_sentiment_related(market_id)
      gather "clientsentiment/related/#{market_id}", :client_sentiments, ClientSentiment
    end
  end

  module GeneralMethods
    def applications
      result = session.get 'operations/application', API_VERSION_1

      result.map { |attributes| Application.new attributes }
    end
  end

  class DealingPlatform
    attr_accessor :session

    def gather(url, collection, klass, api_version = API_VERSION_1)
      session.get(url, api_version).fetch(collection).map do |attributes|
        klass.new attributes
      end
    end

    include SessionMethods
    include AccountMethods
    include DealingMethods
    include MarketMethods
    include WatchlistMethods
    include ClientSentimentMethods
    include GeneralMethods
  end
end
