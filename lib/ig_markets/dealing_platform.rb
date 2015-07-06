module IGMarkets
  module LoginMethods
    # Logs into the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param username [String] the login username
    # @param password [String] the login password
    # @param api_key [String] the login API key
    # @param api [Symbol] the platform to log into, `:production` or `:demo`
    def login(username, password, api_key, platform = :demo)
      session.create username, password, api_key, platform
    end
  end

  module AccountMethods
    def accounts
      session.gather :accounts, '/accounts' do |attributes|
        Account.new attributes
      end
    end

    def activities_in_date_range(from_date, to_date = Date.today)
      from_date = Helper.format_date(from_date)
      to_date = Helper.format_date(to_date)

      session.gather :activities, "/history/activity/#{from_date}/#{to_date}" do |attributes|
        AccountActivity.new attributes
      end
    end

    def activities_in_recent_period(milliseconds)
      session.gather :activities, "/history/activity/#{milliseconds.to_i}" do |attributes|
        AccountActivity.new attributes
      end
    end

    def transactions_in_date_range(from_date, to_date = Date.today, transaction_type = :all)
      from_date = Helper.format_date(from_date)
      to_date = Helper.format_date(to_date)

      validate_transaction_type! transaction_type

      session.gather :transactions, "/history/transactions/#{transaction_type}/#{from_date}/#{to_date}" do |attributes|
        Transaction.new attributes
      end
    end

    def transactions_in_recent_period(milliseconds, transaction_type = :all)
      validate_transaction_type! transaction_type

      session.gather :transactions, "/history/transactions/#{transaction_type}/#{milliseconds}" do |attributes|
        Transaction.new attributes
      end
    end

    private

    ALLOWED_TRANSACTION_TYPES = [:all, :all_deal, :deposit, :withdrawal]

    def validate_transaction_type!(type)
      fail ArgumentError, 'transaction_type is invalid' unless ALLOWED_TRANSACTION_TYPES.include? type
    end
  end

  module DealingMethods
    def positions
      session.gather :positions, '/positions' do |attributes|
        Position.new attributes.merge(market: attributes.fetch(:market))
      end
    end

    def position(deal_id)
      _, result = session.get("/positions/#{deal_id}")

      Position.new result.fetch(:position).merge(market: result.fetch(:market))
    end

    def sprint_market_positions
      session.gather :sprint_market_positions, '/positions/sprintmarkets' do |attributes|
        SprintMarketPosition.new attributes
      end
    end

    def working_orders
      session.gather :working_orders, '/workingorders' do |attributes|
        WorkingOrder.new attributes.merge(market: attributes.fetch(:market_data))
      end
    end
  end

  module MarketMethods
    def market_hierarchy(node_id = nil)
      url = ['/marketnavigation', node_id].compact.join('/')

      _, result = session.get(url)

      {
        markets: (result.fetch(:markets) || []).map { |attributes| Market.new attributes },
        nodes:   (result.fetch(:nodes) || []).map   { |attributes| MarketHierarchyNode.new attributes }
      }
    end

    def market(*epics)
      fail ArgumentError, 'at least one epic must be specified' if epics.empty?

      _, result = session.get("/markets?epics=#{epics.join(',')}")

      result.fetch(:market_details).map do |attributes|
        {
          dealing_rules: parse_market_dealing_rules(attributes.fetch(:dealing_rules)),
          instrument: Instrument.new(attributes.fetch(:instrument)),
          snapshot: MarketSnapshot.new(attributes.fetch(:snapshot))
        }
      end
    end

    def market_search(search_term)
      session.gather :markets, "/markets?searchTerm=#{search_term}" do |attributes|
        Market.new attributes
      end
    end

    def prices(epic, resolution, num_points)
      validate_historical_price_resolution! resolution

      gather_prices "/prices/#{epic}/#{resolution}/#{num_points.to_i}"
    end

    def prices_in_date_range(epic, resolution, start_date_time, end_date_time = DateTime.now)
      validate_historical_price_resolution! resolution

      start_date_time = Helper.format_date_time(start_date_time)
      end_date_time = Helper.format_date_time(end_date_time)

      gather_prices "/prices/#{epic}/#{resolution}?startdate=#{start_date_time}&enddate=#{end_date_time}"
    end

    private

    def parse_market_dealing_rules(raw_dealing_rules)
      dealing_rules = {}

      raw_dealing_rules.each do |k, v|
        v = DealingRule.new(v) if v.is_a? Hash
        dealing_rules[k] = v
      end

      dealing_rules
    end

    ALLOWED_HISTORICAL_PRICE_RESOLUTIONS = [
      :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30,
      :hour, :hour_2, :hour_3, :hour_4,
      :day, :week, :month
    ]

    def validate_historical_price_resolution!(resolution)
      fail ArgumentError, 'resolution is invalid' unless ALLOWED_HISTORICAL_PRICE_RESOLUTIONS.include? resolution
    end

    def gather_prices(url)
      _, result = session.get(url)

      {
        allowance: HistoricalPriceDataAllowance.new(result.fetch(:allowance)),
        instrument_type: result.fetch(:instrument_type),
        prices: result.fetch(:prices).map { |attributes| HistoricalPriceSnapshot.new attributes }
      }
    end
  end

  module WatchlistMethods
    def watchlists
      session.gather :watchlists, '/watchlists' do |attributes|
        Watchlist.new attributes
      end
    end

    def watchlist_markets(watchlist_id)
      session.gather :markets, "/watchlists/#{watchlist_id}" do |attributes|
        Market.new attributes
      end
    end
  end

  module ClientSentimentMethods
    def client_sentiment(market_id)
      _, result = session.get("/clientsentiment/#{market_id}")
      ClientSentiment.new result
    end

    def client_sentiment_related(market_id)
      session.gather :client_sentiments, "/clientsentiment/related/#{market_id}" do |attributes|
        ClientSentiment.new attributes
      end
    end
  end

  module GeneralMethods
    def applications
      _, result = session.get('/operations/application')

      result.map do |attributes|
        Application.new attributes
      end
    end
  end

  class DealingPlatform
    attr_reader :session

    def initialize
      @session = Session.new
    end

    include LoginMethods
    include AccountMethods
    include DealingMethods
    include MarketMethods
    include WatchlistMethods
    include ClientSentimentMethods
    include GeneralMethods
  end
end
