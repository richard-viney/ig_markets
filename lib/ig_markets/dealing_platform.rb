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

    # @return [ClientAccountSummary] The summary of the client account that is returned as part of a successful sign in.
    attr_reader :client_account_summary

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

    # Signs in to the IG Markets Dealing Platform, either the live platform or the demo platform.
    #
    # @param [String] username The account username.
    # @param [String] password The account password.
    # @param [String] api_key The account API key.
    # @param [:live, :demo] platform The platform to use.
    #
    # @return [ClientAccountSummary] The client account summary returned by the sign in request. This result can also
    #                                be accessed through the {#client_account_summary} accessor.
    def sign_in(username, password, api_key, platform)
      session.username = username
      session.password = password
      session.api_key = api_key
      session.platform = platform

      result = session.sign_in

      @client_account_summary = instantiate_models ClientAccountSummary, result
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

    # Disables the API key currently in use by the logged in session. This means that any further requests to the IG
    # Markets API with this key will fail with the error `error.security.api-key-disabled`. Disabled API keys can only
    # be re-enabled through the web platform.
    #
    # @return [Application]
    def disable_api_key
      instantiate_models Application, session.put('operations/application/disable')
    end

    # This method is used to instantiate the various `Model` subclasses from data returned by the IG Markets API. It
    # recurses through arrays and sub-hashes present in `source`, instantiating the required models based on the types
    # of each attribute as defined on the models. All model instances returned by this method will have their
    # `@dealing_platform` instance variable set.
    #
    # @param [Class] model_class The top-level model class to create from `source`.
    # @param [nil, Hash, Array, Model] source The source object to construct the model(s) from. If `nil` then `nil` is
    #                                  returned. If an instance of `model_class` subclass then a deep copy of it is
    #                                  returned. If a `Hash` then it will be interpreted as the attributes for a new
    #                                  instance of `model_class. If an `Array` then each entry will be passed through
    #                                  this method individually.
    #
    # @return [nil, `model_class`, Array<`model_class`>] The resulting instantiated model(s).
    def instantiate_models(model_class, source)
      return nil if source.nil?

      source = prepare_source model_class, source

      if source.is_a? Array
        source.map { |entry| instantiate_models model_class, entry }
      elsif source.is_a? Hash
        instantiate_model_from_attributes_hash model_class, source
      else
        raise ArgumentError, "#{model_class}: can't instantiate from a source of type #{source.class}"
      end
    end

    private

    # This method is a helper for {#instantiate_models} that prepares a source object for instantiation.
    def prepare_source(model_class, source)
      source = source.attributes if source.is_a? model_class

      if source.is_a?(Hash) && model_class.respond_to?(:adjusted_api_attributes)
        source = model_class.adjusted_api_attributes source
      end

      source
    end

    # This method is a companion to {#instantiate_models} and creates a single instance of `model_class` from the passed
    # attributes hash, setting the `@dealing_platform` instance variable on the new model instance.
    def instantiate_model_from_attributes_hash(model_class, attributes)
      model_class.new.tap do |model|
        model.instance_variable_set :@dealing_platform, self

        attributes.each do |attribute, value|
          next unless model_class.valid_attribute? attribute

          type = model_class.attribute_type attribute
          value = instantiate_models(type, value) if type < Model

          model.send "#{attribute}=", value
        end
      end
    end
  end
end
