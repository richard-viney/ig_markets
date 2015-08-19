module IGMarkets
  class Model
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = {}

      defined_attributes = (self.class.defined_attributes || {}).keys

      defined_attributes.each do |name|
        send "#{name}=", attributes[name]
      end

      invalid_attributes = attributes.keys - defined_attributes
      fail ArgumentError, "Unknown attributes: #{invalid_attributes.join ', '}" unless invalid_attributes.empty?
    end

    def ==(other)
      attributes == other.attributes
    end

    def inspect
      "#<#{self.class.name} #{attributes.map { |k, v| "#{k}: #{v}" }.join(', ')}>"
    end

    class << self
      attr_accessor :defined_attributes

      def attribute(name, options = {})
        name = name.to_sym

        define_attribute_reader name
        define_attribute_writer name, options

        self.defined_attributes ||= {}
        self.defined_attributes[name] = options
      end

      def from(source)
        return nil if source.nil?
        return new source if source.is_a? Hash
        return source.dup if source.is_a? self
        return source.map { |item| from item } if source.is_a? Array

        fail ArgumentError, "Unable to make a #{self} from instance of #{source.class}"
      end

      private

      def define_attribute_reader(name)
        define_method name do
          @attributes[name]
        end
      end

      def define_attribute_writer(name, options)
        type = options.delete :type

        typecaster = nil
        if type.is_a? Symbol
          typecaster = method "typecaster_#{type}"
        elsif type.respond_to? :from
          typecaster = -> (value, _options) { type.from value }
        end

        define_method "#{name}=" do |value|
          @attributes[name] = typecaster ? typecaster.call(value, options) : value
        end
      end

      def typecaster_boolean(value, _options)
        return value if [nil, true, false].include? value

        fail ArgumentError, "Invalid boolean value: #{value}"
      end

      def typecaster_date_time(value, options)
        fail ArgumentError, 'Invalid or missing date time format' unless options[:format].is_a? String

        value = nil if value == ''

        if value.is_a? String
          DateTime.strptime(value, options[:format])
        else
          value
        end
      end

      def typecaster_float(value, _options)
        value && Float(value)
      end
    end
  end
end
