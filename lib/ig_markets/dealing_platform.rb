module IGMarkets
  # This is the primary class for interacting with the IG Markets API. After signing in using {#sign_in} most
  # functionality is accessed via the following top-level methods:
  #
  # - {#account}
  # - {#client_sentiment}
  # - {#markets}
  # - {#positions}
  # - {#sprint_market_positions}
  # - {#watchlists}
  # - {#working_orders}
  #
  # See `README.md` for examples.
  #
  # If any errors occur while executing requests to the IG Markets API then {RequestFailedError} will be raised.
  class DealingPlatform
    # @return [Session] The session used by this dealing platform.
    attr_reader :session

    # @return [AccountMethods] Methods for working with the logged in account.
    attr_reader :account

    # @return [ClientSentimentMethods] Methods for working with client sentiment.
    attr_reader :client_sentiment

    # @return [MarketMethods] Methods for working with markets.
    attr_reader :markets

    # @return [PositionMethods] Methods for working with positions.
    attr_reader :positions

    # @return [SprintMarketPositionMethods] Methods for working with sprint market positions.
    attr_reader :sprint_market_positions

    # @return [WatchlistMethods] Methods for working with watchlists.
    attr_reader :watchlists

    # @return [WorkingOrderMethods] Methods for working with working orders.
    attr_reader :working_orders

    def initialize
      @session = Session.new

      @account = AccountMethods.new self
      @client_sentiment = ClientSentimentMethods.new self
      @markets = MarketMethods.new self
      @positions = PositionMethods.new self
      @sprint_market_positions = SprintMarketPositionMethods.new self
      @watchlists = WatchlistMethods.new self
      @working_orders = WorkingOrderMethods.new self
    end

    # Signs in to the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param [String] username The account username.
    # @param [String] password The account password.
    # @param [String] api_key The account API key.
    # @param [:production, :demo] platform The platform to use.
    def sign_in(username, password, api_key, platform)
      session.username = username
      session.password = password
      session.api_key = api_key
      session.platform = platform

      session.sign_in
    end

    # Signs out of the IG Markets Dealing Platform, ending any current session.
    def sign_out
      session.sign_out
    end

    # Returns a full deal confirmation for the specified deal reference.
    #
    # @return [DealConfirmation]
    def deal_confirmation(deal_reference)
      instantiate_models DealConfirmation, session.get("confirms/#{deal_reference}")
    end

    # Returns details on the IG Markets applications for the accounts associated with this login.
    #
    # @return [Array<Application>]
    def applications
      instantiate_models Application, session.get('operations/application')
    end

    # This method is used to instantiate the various `Model` subclasses from data returned by the IG Markets API. It
    # recurses through arrays and sub-hashes present in `source`, instantiating the required models based on the types
    # of each attribute as defined on the models. All model instances returned by this method will have their
    # `@dealing_platform` instance variable set.
    #
    # @param [Class] model_class The type of model to create from `source`.
    # @param [nil, Hash, Array, Model] source The source object to construct the model(s) from. If `nil` then `nil` is
    #                                  returned. If an instance of `model_class` subclass then a deep copy of it is
    #                                  returned. If a `Hash` then it will be interprted as the attributes for a new
    #                                  instance of `model_class. If an `Array` then each entry will be passed through
    #                                  this method individually.
    #
    # @return [nil, `model_class`, Array<`model_class`>] The resulting instantiated model(s).
    def instantiate_models(model_class, source)
      return nil if source.nil?

      source = source.attributes if source.is_a? model_class

      if source.is_a? Array
        source.map { |entry| instantiate_models model_class, entry }
      elsif source.is_a? Hash
        source = model_class.adjusted_api_attributes source if model_class.respond_to? :adjusted_api_attributes

        instantiate_model_from_attributes_hash model_class, source
      else
        raise ArgumentError, "#{model_class}: can't instantiate from a source of type #{source.class}"
      end
    end

    private

    # This method is a companion to {#instantiate_models} and creates a single instance of `model_class` from the passed
    # attributes hash, setting the `@dealing_platform` instance variable on the new model instance.
    def instantiate_model_from_attributes_hash(model_class, attributes)
      model_class.new.tap do |model|
        model.instance_variable_set :@dealing_platform, self

        attributes.each do |attribute, value|
          type = model_class.attribute_type attribute
          value = instantiate_models(type, value) if type < Model

          model.send "#{attribute}=", value
        end
      end
    end
  end
end
