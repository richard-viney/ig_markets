module IGMarkets
  # This class is intended to be subclassed in order to create models that contain a set of attributes, where each
  # attribute is defined by a call to {attribute}. Attributes have standard getter and setter methods and can also
  # be subject to a variety of constraints and validations, see {attribute} for further details.
  class Model
    # The current attribute values set on this model.
    #
    # @return [Hash]
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

    # Mass assigns the passed attributes to this model.
    #
    # @param [Hash] new_attributes The attributes to assign on this model.
    def attributes=(new_attributes)
      new_attributes.each do |name, value|
        send "#{name}=", value
      end
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
      # A hash containing details of all attributes that have been defined on this model.
      #
      # @return [Hash]
      attr_accessor :defined_attributes

      # The names of the deprecated attributes on this model.
      #
      # @return [Array]
      attr_accessor :deprecated_attributes

      # Returns the names of all currently defined attributes for this model.
      #
      # @return [Array<Symbol>]
      def defined_attribute_names
        Hash(defined_attributes).keys
      end

      # Returns whether the passed value is a valid attribute name. If the passed attribute name is not recognized then
      # an error will be printed to `stderr`. Only one warning will be printed for each unrecognized attribute.
      #
      # @param [Symbol] name The candidate attribute name.
      #
      # @return [Boolean]
      def valid_attribute?(name)
        return true if defined_attribute_names.include?(name) || Array(deprecated_attributes).include?(name)

        unless Array(@reported_invalid_attributes).include? name
          warn "ig_markets: unrecognized attribute #{self}##{name}"
          (@reported_invalid_attributes ||= []) << name
        end

        false
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

      # Returns whether the passed value is allowed to set be set as the value of the specified attribute.
      #
      # @param [Symbol] attribute_name
      # @param value The candidate attribute value.
      #
      # @return [Boolean] Whether the passed value is allowed for the attribute.
      def attribute_value_allowed?(attribute_name, value)
        allowed_values = Hash(defined_attributes).fetch(attribute_name, {})[:allowed_values]

        value.nil? || allowed_values.nil? || allowed_values.include?(value)
      end

      # Defines setter and getter instance methods and a sanitizer class method for a new attribute on this class.
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
        define_attribute_writer name
        define_attribute_sanitizer name, type, options

        @defined_attributes ||= {}
        @defined_attributes[name] = options.merge type: type
      end

      # Defines no-op setter, getter and sanitize methods for each of the passed attribute names. This is used to
      # silently allow deprecated attributes to be used on the model but not have them be part of the model's structure.
      #
      # @param [Array<Symbol>] names The names of the deprecated attributes.
      def deprecated_attribute(*names)
        names.each do |name|
          define_method(name) {}
          define_method("#{name}=") { |_value| }
          define_singleton_method("sanitize_#{name}_value") { |value| value }

          (@deprecated_attributes ||= []) << name
        end
      end

      private

      def define_attribute_reader(name)
        define_method(name) { @attributes[name] }
      end

      def define_attribute_writer(name)
        define_method "#{name}=" do |value|
          value = self.class.send "sanitize_#{name}_value", value

          unless self.class.attribute_value_allowed? name, value
            raise ArgumentError, "#{self}##{name}: invalid value: #{value.inspect}"
          end

          (@attributes ||= {})[name] = value
        end
      end

      def define_attribute_sanitizer(name, type, options)
        typecaster = typecaster_for type

        define_singleton_method "sanitize_#{name}_value" do |value|
          value = nil if Array(options[:nil_if]).include? value

          typecaster.call value, options, name
        end
      end
    end
  end
end
