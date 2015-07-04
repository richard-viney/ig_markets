module IGMarkets
  class DealingPlatform
    attr_reader :session

    def initialize
      @session = Session.new
    end

    def login(options = {})
      session.create options
    end

    ### Account

    def accounts
      gather :accounts do |attributes|
        Account.new attributes
      end
    end

    def activities_in_range(options = {})
      from_date = Helper.format_date(options.fetch(:from_date))
      to_date = Helper.format_date(options.fetch(:to_date))

      gather :activities, "/history/activity/#{from_date}/#{to_date}" do |attributes|
        Activity.new attributes
      end
    end

    def activites_in_last_period(options = {})
      milliseconds = options.fetch(:milliseconds)

      gather :activities, "/history/activity/#{milliseconds}" do |attributes|
        Activity.new attributes
      end
    end

    def transactions_of_type_in_range(options = {})
      transaction_type = options.fetch(:transaction_type)
      from_date = Helper.format_date(options.fetch(:from_date))
      to_date = Helper.format_date(options.fetch(:to_date))

      gather :transactions, "/history/transactions/#{transaction_type}/#{from_date}/#{to_date}" do |attributes|
        Transaction.new attributes
      end
    end

    def transactions_in_last_period(options = {})
      transaction_type = options.fetch(:transaction_type)
      milliseconds = options.fetch(:milliseconds)

      gather :transactions, "/history/transactions/#{transaction_type}/#{milliseconds}" do |attributes|
        Transaction.new attributes
      end
    end

    ### Dealing

    def positions
      gather :positions do |attributes|
        Position.new attributes.fetch(:position).merge(market: Market.new(attributes.fetch(:market)))
      end
    end

    def position(options = {})
      _, result = session.get("/positions/#{options.fetch(:deal_id)}")
      Position.new result.fetch(:position).merge(market: Market.new(result.fetch(:market)))
    end

    ### Watchlists

    def watchlists
      gather :watchlists do |attributes|
        Watchlist.new attributes
      end
    end

    ### Client sentiment

    def client_sentiment(options = {})
      _, result = session.get("/clientsentiment/#{options.fetch(:market_id)}")
      ClientSentiment.new result
    end

    def client_sentiment_related(options = {})
      gather :clientSentiments, "/clientsentiment/related/#{options.fetch(:market_id)}" do |attributes|
        ClientSentiment.new attributes
      end
    end

    private

    def gather(collection, url = nil)
      _, result = session.get(url || "/#{collection}")

      result.fetch(collection).map do |attributes|
        yield attributes
      end
    end
  end
end
