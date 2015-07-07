module IGMarkets
  module LoginMethods
    # Logs into the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param username [String] the login username
    # @param password [String] the login password
    # @param api_key [String] the login API key
    # @param platform [:production, :demo] the platform to log into
    def login(username, password, api_key, platform = :demo)
      session.login username, password, api_key, platform
    end

    # Logs out of the IG Markets Dealing Platform
    def logout
      session.logout
    end
  end

  module AccountMethods
    def accounts
      session.gather(:accounts, '/accounts') { |attributes| Account.new attributes }
    end

    def activities_in_date_range(from_date, to_date = Date.today)
      from_date = format_activity_date(from_date)
      to_date = format_activity_date(to_date)

      gather_activities "/history/activity/#{from_date}/#{to_date}"
    end

    def activities_in_recent_period(milliseconds)
      gather_activities "/history/activity/#{milliseconds.to_i}"
    end

    def transactions_in_date_range(from_date, to_date = Date.today, transaction_type = :all)
      from_date = format_activity_date(from_date)
      to_date = format_activity_date(to_date)

      validate_transaction_type! transaction_type

      gather_transactions "/history/transactions/#{transaction_type.to_s.upcase}/#{from_date}/#{to_date}"
    end

    def transactions_in_recent_period(milliseconds, transaction_type = :all)
      validate_transaction_type! transaction_type

      gather_transactions "/history/transactions/#{transaction_type.to_s.upcase}/#{milliseconds}"
    end

    private

    ALLOWED_TRANSACTION_TYPES = [:all, :all_deal, :deposit, :withdrawal]

    def validate_transaction_type!(type)
      fail ArgumentError, 'transaction_type is invalid' unless ALLOWED_TRANSACTION_TYPES.include? type
    end

    def gather_activities(url)
      session.gather(:activities, url) { |attributes| AccountActivity.new attributes }
    end

    def gather_transactions(url)
      session.gather(:transactions, url) { |attributes| Transaction.new attributes }
    end

    def format_activity_date(d)
      d.strftime '%d-%m-%Y'
    end
  end

  module DealingMethods
    def positions
      session.gather :positions, '/positions', Session::API_VERSION_2 do |attributes|
        Position.new attributes.fetch(:position).merge(market: attributes.fetch(:market))
      end
    end

    def position(deal_id)
      _, result = session.get("/positions/#{deal_id}", Session::API_VERSION_2)

      Position.new result.fetch(:position).merge(market: result.fetch(:market))
    end

    def sprint_market_positions
      session.gather :sprint_market_positions, '/positions/sprintmarkets' do |attributes|
        SprintMarketPosition.new attributes
      end
    end

    def working_orders
      session.gather :working_orders, '/workingorders', Session::API_VERSION_2 do |attributes|
        WorkingOrder.new attributes.fetch(:working_order_data).merge(market: attributes.fetch(:market_data))
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

    def market(epic)
      markets(epic)[0]
    end

    def markets(*epics)
      fail ArgumentError, 'at least one epic must be specified' if epics.empty?

      _, result = session.get("/markets?epics=#{epics.join(',')}")

      result.fetch(:market_details).map do |attributes|
        {
          dealing_rules: parse_dealing_rules(attributes.fetch(:dealing_rules)),
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

      gather_prices "/prices/#{epic}/#{resolution.to_s.upcase}/#{num_points.to_i}"
    end

    def prices_in_date_range(epic, resolution, start_date_time, end_date_time = DateTime.now)
      validate_historical_price_resolution! resolution

      start_date_time = format_historical_price_date_time(start_date_time)
      end_date_time = format_historical_price_date_time(end_date_time)

      gather_prices "/prices/#{epic}/#{resolution.to_s.upcase}/#{start_date_time}/#{end_date_time}"
    end

    private

    ALLOWED_HISTORICAL_PRICE_RESOLUTIONS = [
      :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30,
      :hour, :hour_2, :hour_3, :hour_4,
      :day, :week, :month
    ]

    def parse_dealing_rules(raw_dealing_rules)
      dealing_rules = {
        market_order_preference: raw_dealing_rules.delete(:market_order_preference),
        trailing_stops_preference: raw_dealing_rules.delete(:trailing_stops_preference)
      }

      raw_dealing_rules.each do |k, v|
        dealing_rules[k] = DealingRule.new(v)
      end

      dealing_rules
    end

    def validate_historical_price_resolution!(resolution)
      fail ArgumentError, 'resolution is invalid' unless ALLOWED_HISTORICAL_PRICE_RESOLUTIONS.include? resolution
    end

    def format_historical_price_date_time(dt)
      "#{dt.strftime('%Y-%m-%d')}%20#{dt.strftime('%H:%M:%S')}"
    end

    def gather_prices(url)
      _, result = session.get(url, Session::API_VERSION_2)

      {
        allowance: HistoricalPriceDataAllowance.new(result.fetch(:allowance)),
        instrument_type: result.fetch(:instrument_type),
        prices: result.fetch(:prices).map { |attributes| HistoricalPriceSnapshot.new attributes }
      }
    end
  end

  module WatchlistMethods
    def watchlists
      session.gather(:watchlists, '/watchlists') { |attributes| Watchlist.new attributes }
    end

    def watchlist_markets(watchlist_id)
      session.gather(:markets, "/watchlists/#{watchlist_id}") { |attributes| Market.new attributes }
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

      result.map { |attributes| Application.new attributes }
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
