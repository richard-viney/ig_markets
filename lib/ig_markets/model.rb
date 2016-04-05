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
        value = value.inspect unless value.is_a? DateTime

        raise ArgumentError, "Unknown attribute: #{self.class.name}##{attribute}, value: #{value}"
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
        value = send attribute

        "#{attribute}: #{value.is_a?(DateTime) ? value : value.inspect}"
      end

      "#<#{self.class.name} #{formatted_attributes.join ', '}>"
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
      # @param [Boolean, String, DateTime, Fixnum, Float, Symbol, #from] type The attribute's type.
      # @param [Hash] options The configuration options for the new attribute.
      # @option options [Array] :allowed_values The set of values that this attribute is allowed to be set to. An
      #                 attempt to set this attribute to a value not in this list will raise `ArgumentError`. Optional.
      # @option options [Array] :nil_if Values that, when set on the attribute, should be converted to `nil`.
      # @option options [Regexp] :regex When `type` is `String` only values matching this regex will be allowed.
      #                 Optional.
      # @option options [String] :format When `type` is `DateTime` this specifies the format for parsing String and
      #                 Fixnum instances assigned to this attribute. See `DateTime#strptime` for details.
      #
      # @macro [attach] attribute
      #   The $1 attribute.
      #   @return [$2]
      def attribute(name, type = String, options = {})
        define_attribute_reader name
        define_attribute_writer name, type, options

        (self.defined_attributes ||= {})[name] = options.merge type: type
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

          value = typecaster.call(value, options)

          allowed_values = options[:allowed_values]
          if !value.nil? && allowed_values
            raise ArgumentError, "#{self}##{name}: invalid value: #{value.inspect}" unless allowed_values.include? value
          end

          (@attributes ||= {})[name] = value
        end
      end

      def typecaster_for(type)
        if [Boolean, String, Fixnum, Float, Symbol, DateTime].include? type
          method "typecaster_#{type.to_s.gsub(/\AIGMarkets::/, '').downcase}"
        elsif type.respond_to? :from
          -> (value, _options) { type.from value }
        end
      end

      def typecaster_boolean(value, _options)
        return value if [nil, true, false].include? value

        raise ArgumentError, "#{self}: invalid boolean value: #{value}"
      end

      def typecaster_string(value, options)
        return nil if value.nil?

        if options.key? :regex
          raise ArgumentError, "#{self}: invalid string value: #{value}" unless options[:regex].match value.to_s
        end

        value.to_s
      end

      def typecaster_fixnum(value, _options)
        value.nil? ? nil : value.to_s.to_i
      end

      def typecaster_float(value, _options)
        value.nil? ? nil : Float(value)
      end

      def typecaster_symbol(value, _options)
        value.nil? ? nil : value.to_s.downcase.to_sym
      end

      def typecaster_datetime(value, options)
        raise ArgumentError, "#{self}: invalid or missing date time format" unless options[:format].is_a? String

        if value.is_a?(String) || value.is_a?(Fixnum)
          begin
            DateTime.strptime(value.to_s, options[:format])
          rescue ArgumentError
            raise ArgumentError, "#{self}: failed parsing date '#{value}' with format '#{options[:format]}'"
          end
        else
          value
        end
      end
    end
  end
end
