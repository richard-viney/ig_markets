module IGMarkets
  # This is the primary class for interacting with the IG Markets API. After signing in using {#sign_in} most
  # functionality can be accessed using the following methods:
  #
  # - {#account}
  # - {#client_sentiment}
  # - {#markets}
  # - {#positions}
  # - {#sprint_market_positions}
  # - {#watchlists}
  # - {#working_orders}
  # - {#streaming}
  #
  # See `README.md` for code examples.
  #
  # If any errors occur while executing requests to the IG Markets API then an {IGMarketsError} subclass will be raised.
  class DealingPlatform
    # The session used by this dealing platform.
    #
    # @return [Session]
    attr_reader :session

    # The summary of the client account that is returned as part of a successful sign in.
    #
    # @return [ClientAccountSummary]
    attr_reader :client_account_summary

    # Methods for working with the balances and history of the logged in account.
    #
    # @return [AccountMethods]
    attr_reader :account

    # Methods for working with client sentiment.
    #
    # @return [ClientSentimentMethods]
    attr_reader :client_sentiment

    # Methods for working with markets.
    #
    # @return [MarketMethods]
    attr_reader :markets

    # Methods for working with positions.
    #
    # @return [PositionMethods]
    attr_reader :positions

    # Methods for working with sprint market positions.
    #
    # @return [SprintMarketPositionMethods]
    attr_reader :sprint_market_positions

    # Methods for working with watchlists.
    #
    # @return [WatchlistMethods]
    attr_reader :watchlists

    # Methods for working with working orders.
    #
    # @return [WorkingOrderMethods]
    attr_reader :working_orders

    # Methods for working with live streaming of IG Markets data.
    #
    # @return [StreamingMethods]
    attr_reader :streaming

    def initialize
      @session = Session.new

      @account = AccountMethods.new self
      @client_sentiment = ClientSentimentMethods.new self
      @markets = MarketMethods.new self
      @positions = PositionMethods.new self
      @sprint_market_positions = SprintMarketPositionMethods.new self
      @watchlists = WatchlistMethods.new self
      @working_orders = WorkingOrderMethods.new self
      @streaming = StreamingMethods.new self
    end

    # Signs in to the IG Markets Dealing Platform, either the live platform or the demo platform.
    #
    # @param [String] username The IG Markets username.
    # @param [String] password The IG Markets password.
    # @param [String] api_key The IG Markets API key.
    # @param [:live, :demo] platform The platform to use.
    #
    # @return [ClientAccountSummary] The client account summary returned by the sign in request. This result can also
    #                                be accessed later using {#client_account_summary}.
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
      streaming.disconnect
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

    # Disables the API key currently being used by the logged in session. This means that any further requests to the IG
    # Markets API with this key will raise {Errors::APIKeyDisabledError}. Disabled API keys can only be re-enabled
    # through the web platform.
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
    #
    # @private
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

    # This method is the same as {#instantiate_models} but takes an unparsed JSON string as its input.
    #
    # @param [Class] model_class The top-level model class to create from `json`.
    # @param [String] json The JSON string to parse.
    #
    # @return [nil, `model_class`] The resulting instantiated model.
    #
    # @private
    def instantiate_models_from_json(model_class, json)
      instantiate_models model_class, ResponseParser.parse(JSON.parse(json))
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
          next unless model.class.valid_attribute? attribute

          type = model.class.attribute_type attribute
          value = instantiate_models type, value if type < Model

          set_model_attribute_value model, attribute, value
        end
      end
    end

    # Sets the specified attribute value on the passed model instance. If a future version of the IG Markets API adds
    # new valid values for attributes that are of type `Symbol` then assigning them here would cause an `ArgumentError`
    # exception due to them not being in the `allowed_values` list for the attribute. This means that an API addition
    # by IG Markets could cause this library to crash, which is undesirable. Instead of crashing this method issues a
    # warning about the unrecognized value, and a future version of this library can then be updated to properly support
    # the new valid value(s) that were added in the API update.
    def set_model_attribute_value(model, attribute, value)
      value = model.class.send "sanitize_#{attribute}_value", value

      if model.class.attribute_value_allowed? attribute, value
        model.send "#{attribute}=", value
      else
        unless Array(@reported_unrecognized_values).include? [model.class, attribute, value]
          warn "ig_markets: received unrecognized value for #{model.class}##{attribute}: #{value}"
          (@reported_unrecognized_values ||= []) << [model.class, attribute, value]
        end
      end
    end
  end
end
