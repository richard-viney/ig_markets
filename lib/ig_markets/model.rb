module IGMarkets
  # This class is intended to be subclassed in order to create models that contain a set of attributes, where each
  # attribute is defined by a call to {attribute}. Attributes have standard getter and setter methods and can also
  # be subject to a variety of constraints and validations, see {attribute} for further details.
  class Model
    # @return [Hash] The current attribute values set on this model.
    attr_reader :attributes

    # Initializes this new model with the given attribute values. Attributes not known to this model will raise
    # `ArgumentError`.
    #
    # @param [Hash] attributes The attribute values to set on this new model.
    def initialize(attributes = {})
      self.class.defined_attribute_names.each do |name|
        send "#{name}=", attributes[name]
      end

      attributes.each do |name, value|
        next if respond_to? "#{name}="

        raise ArgumentError, "unknown attribute: #{self.class.name}##{name}, value: #{inspect_value value}"
      end
    end

    # Copy initializer that duplicates the {#attributes} hash in full.
    #
    # @param [Model] other The model to copy.
    def initialize_copy(other)
      super

      @attributes = other.attributes.dup
    end

    # Compares this model to another, the attributes and class must match for them to be considered equal.
    #
    # @param [#class, #attributes] other The other model to compare to.
    #
    # @return [Boolean]
    def ==(other)
      self.class == other.class && attributes == other.attributes
    end

    # Returns a human-readable string containing this model's type and all its current attribute values.
    #
    # @return [String]
    def inspect
      formatted_attributes = self.class.defined_attribute_names.map do |attribute|
        "#{attribute}: #{inspect_value send(attribute)}"
      end

      "#<#{self.class.name} #{formatted_attributes.join ', '}>"
    end

    private

    # Returns the {#inspect} string for the given value.
    def inspect_value(value)
      if value.is_a? Time
        value.localtime.strftime '%F %T %Z'
      elsif value.is_a? Date
        value.strftime '%F'
      else
        value.inspect
      end
    end

    class << self
      # @return [Hash] A hash containing details of all attributes that have been defined on this model.
      attr_accessor :defined_attributes

      # @return [Hash] The names of the deprecated attributes on this model.
      attr_accessor :deprecated_attributes

      # Returns the names of all currently defined attributes for this model.
      #
      # @return [Array<Symbol>]
      def defined_attribute_names
        Hash(defined_attributes).keys
      end

      # Returns the type of the specified attribute.
      #
      # @param [Symbol] attribute_name The name of the attribute to return the type for.
      #
      # @return The type of the specified attribute.
      def attribute_type(attribute_name)
        return NilClass if Array(deprecated_attributes).include? attribute_name

        Hash(defined_attributes).fetch(attribute_name).fetch :type
      end

      # Returns the array of allowed values for the specified attribute that was passed to {attribute}.
      #
      # @param [Symbol] attribute_name The name of the attribute to return the allowed values for.
      #
      # @return [Array]
      def allowed_values(attribute_name)
        Hash(defined_attributes).fetch(attribute_name).fetch :allowed_values
      end

      # Defines setter and getter methods for a new attribute on this class.
      #
      # @param [Symbol] name The name of the new attribute.
      # @param [Boolean, String, Date, Time, Fixnum, Float, Symbol, Model] type The attribute's type.
      # @param [Hash] options The configuration options for the new attribute.
      # @option options [Array] :allowed_values The set of values that this attribute is allowed to be set to. An
      #                 attempt to set this attribute to a value not in this list will raise `ArgumentError`. Optional.
      # @option options [Array] :nil_if Values that, when set on the attribute, should be converted to `nil`.
      # @option options [Regexp] :regex When `type` is `String` only values matching this regex will be allowed.
      #                 Optional.
      # @option options [String] :format When `type` is `Date` or `Time` this specifies the format or formats for
      #                 parsing String and `Fixnum` instances assigned to this attribute.
      #
      # @macro [attach] attribute
      #   The $1 attribute.
      #   @return [$2]
      def attribute(name, type = String, options = {})
        define_attribute_reader name
        define_attribute_writer name, type, options

        self.defined_attributes ||= {}
        self.defined_attributes[name] = options.merge type: type
      end

      # Defines a no-op setter method for each of the passed attribute names. This is used to silently allow deprecated
      # attributes to be set on the model but not have them be part of the model's structure.
      #
      # @param [Array<Symbol>] names The names of the deprecated attributes.
      def deprecated_attribute(*names)
        names.each do |name|
          define_method "#{name}=" do |_value|
          end

          (self.deprecated_attributes ||= []) << name
        end
      end

      private

      def define_attribute_reader(name)
        define_method(name) { @attributes[name] }
      end

      def define_attribute_writer(name, type, options)
        typecaster = typecaster_for type

        define_method "#{name}=" do |value|
          value = nil if Array(options.fetch(:nil_if, [])).include? value

          value = typecaster.call value, options, name

          allowed_values = options[:allowed_values]
          if !value.nil? && allowed_values
            raise ArgumentError, "#{self}##{name}: invalid value: #{value.inspect}" unless allowed_values.include? value
          end

          (@attributes ||= {})[name] = value
        end
      end
    end
  end
end
