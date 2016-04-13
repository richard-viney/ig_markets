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
      defined_attribute_names = self.class.defined_attribute_names

      defined_attribute_names.each do |name|
        send "#{name}=", attributes[name]
      end

      (attributes.keys - defined_attribute_names).map do |attribute|
        value = attributes[attribute]

        raise ArgumentError, "Unknown attribute: #{self.class.name}##{attribute}, value: #{inspect_value value}"
      end
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

    # Returns the #inspect string for the given value.
    def inspect_value(value)
      if value.is_a? Time
        value.strftime '%F %T %z'
      elsif value.is_a? Date
        value.strftime '%F'
      else
        value.inspect
      end
    end

    class << self
      # @return [Hash] A hash containing details of all attributes that have been defined on this model.
      attr_accessor :defined_attributes

      # Returns the names of all currently defined attributes for this model.
      #
      # @return [Array<Symbol>]
      def defined_attribute_names
        (defined_attributes || {}).keys
      end

      # Returns the array of allowed values for the specified attribute that was passed to {attribute}.
      #
      # @param [Symbol] attribute_name The name of the attribute to return the allowed values for.
      #
      # @return [Array]
      def allowed_values(attribute_name)
        defined_attributes.fetch(attribute_name).fetch(:allowed_values)
      end

      # Defines setter and getter methods for a new attribute on this class.
      #
      # @param [Symbol] name The name of the new attribute.
      # @param [Boolean, String, Date, Time, Fixnum, Float, Symbol, #from] type The attribute's type.
      # @param [Hash] options The configuration options for the new attribute.
      # @option options [Array] :allowed_values The set of values that this attribute is allowed to be set to. An
      #                 attempt to set this attribute to a value not in this list will raise `ArgumentError`. Optional.
      # @option options [Array] :nil_if Values that, when set on the attribute, should be converted to `nil`.
      # @option options [Regexp] :regex When `type` is `String` only values matching this regex will be allowed.
      #                 Optional.
      # @option options [String] :format When `type` is `Date` or `Time` this specifies the format for parsing String
      #                 and `Fixnum` instances assigned to this attribute.
      # @option options [String] :time_zone When `type` is `Time` this specifies the time zone to append to
      #                 `String` values assigned to this attribute prior to parsing them with `:format`. Optional.
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

      # Creates a new Model instance from the specified source, which can take a variety of different forms.
      #
      # @param [nil, Hash, Model, Array] source The source object to create a new `Model` instance from. If `source` is
      #        `nil` then `nil` is returned. If `source` is a hash then a new `Model` instance is returned and the
      #        hash is passed to `Model#initialize`. If `source` is an instance of this class then `dup` is called on it
      #        and the duplicate returned. If source is an array then it is mapped into a new array with each item
      #        having been recursively passed through this method.
      #
      # @return [nil, Array, Model]
      def from(source)
        return nil if source.nil?
        return new source if source.is_a? Hash
        return source.dup if source.is_a? self
        return source.map { |item| from item } if source.is_a? Array

        raise ArgumentError, "Unable to make a #{self} from instance of #{source.class}"
      end

      private

      def define_attribute_reader(name)
        define_method(name) { @attributes[name] }
      end

      def define_attribute_writer(name, type, options)
        typecaster = typecaster_for type

        define_method "#{name}=" do |value|
          value = nil if Array(options.fetch(:nil_if, [])).include? value

          value = typecaster.call value, options

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
