module IGMarkets
  # This class is intended to be subclassed in order to create models that contain a set of attributes, where each
  # attribute is defined by a call to {attribute}. Attributes have standard getter and setter methods and can also
  # be subject to a variety of constraints and validations, see {attribute} for further details.
  class Model
    attr_reader :attributes

    # Initializes this new model with the given attribute values. Attributes not known to this model will raise
    # `ArgumentError`.
    #
    # @param [Hash] attributes The attribute values hash to set on this new model.
    #
    # @return [void]
    def initialize(attributes = {})
      @attributes = {}

      defined_attributes = self.class.defined_attributes || []

      defined_attributes.each do |name|
        send "#{name}=", attributes[name]
      end

      (attributes.keys - defined_attributes).map do |attribute|
        value = attributes[attribute]
        value = value.inspect unless value.is_a? DateTime

        raise ArgumentError, "Unknown attribute: #{self.class.name}##{attribute}, value: #{value}"
      end
    end

    # Compares this model's attributes to another's.
    #
    # @return [Boolean]
    def ==(other)
      attributes == other.attributes
    end

    # Returns a human-readable string containing this model's type and all its current attribute values.
    #
    # @return [String]
    def inspect
      formatted_attributes = self.class.defined_attributes.map do |attribute|
        value = send attribute
        value = value.inspect unless value.is_a? DateTime

        "#{attribute}: #{value}"
      end

      "#<#{self.class.name} #{formatted_attributes.join ', '}>"
    end

    class << self
      attr_accessor :defined_attributes

      # Defines setter and getter methods for a new attribute on this class.
      #
      # @param [Symbol] name The name of the new attribute.
      # @param [Hash] options The options
      # @option options [:boolean, :string, :date_time, :float, :symbol, :object, #from] :type The attribute's type.
      # @option options [Array] :allowed_values The set of values that this attribute is allowed to be set to. An
      #                         attempt to set this attribute to a value not in this list will raise `ArgumentError`.
      #                         Optional.
      # @option options [Array] :nil_if Values that, when set on the attribute, should be converted to `nil`.
      # @option options [Regexp] :regex When `:type` is `:string` only values matching this regex will be allowed.
      #                                 Optional.
      # @option options [String] :format When `:type` is `:date_time` this specifies the format for parsing strings
      #                          assigned to this attribute. See `DateTime#strptime` for details.
      #
      # @return [void]
      def attribute(name, options = {})
        name = name.to_sym

        options[:type] ||= :object

        define_attribute_reader name
        define_attribute_writer name, options

        self.defined_attributes = (defined_attributes || []) << name
      end

      # Creates a new Model instance from the specified source, which can take a variety of different forms.
      #
      # @param [nil, Hash, Model, Array] source The source object to create a new `Model` instance from. If `source` is
      #                                         `nil` then `nil` is returned. If `source` is a `Hash` then a new `Model`
      #                                         instance is returned and the hash passed to `Model#initialize`. If
      #                                         `source` is an instance of this class then `#dup` is called and the
      #                                         duplicate returned. If source is an `Array` then it is mapped into a new
      #                                         `Array` with each item having been recursively passed through this
      #                                         `#from` method.
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
        define_method name do
          @attributes[name]
        end
      end

      def define_attribute_writer(name, options)
        typecaster = typecaster_for options[:type]

        define_method "#{name}=" do |value|
          value = nil if Array(options.fetch(:nil_if, [])).include? value

          value = typecaster.call(value, options)

          allowed_values = options[:allowed_values]
          if !value.nil? && allowed_values
            raise ArgumentError, "Invalid value: #{value.inspect}" unless allowed_values.include? value
          end

          @attributes[name] = value
        end
      end

      def typecaster_for(type)
        if type.is_a? Symbol
          method "typecaster_#{type}"
        elsif type.respond_to? :from
          -> (value, _options) { type.from value }
        end
      end

      def typecaster_object(value, _options)
        value
      end

      def typecaster_boolean(value, _options)
        return value if [nil, true, false].include? value

        raise ArgumentError, "Invalid boolean value: #{value}"
      end

      def typecaster_string(value, options)
        return nil if value.nil?

        string = value.to_s

        if options.key? :regex
          raise ArgumentError, "Invalid string value: #{string}" unless options[:regex].match string
        end

        string
      end

      def typecaster_float(value, _options)
        value && Float(value)
      end

      def typecaster_symbol(value, _options)
        return nil if value.nil?

        value.to_s.downcase.to_sym
      end

      def typecaster_date_time(value, options)
        raise ArgumentError, 'Invalid or missing date time format' unless options[:format].is_a? String

        if value.is_a?(String) || value.is_a?(Fixnum)
          begin
            DateTime.strptime(value.to_s, options[:format])
          rescue ArgumentError
            raise ArgumentError, "Failed parsing date '#{value}' with format '#{options[:format]}'"
          end
        else
          value
        end
      end
    end
  end
end
