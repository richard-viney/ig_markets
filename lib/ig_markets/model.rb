module IGMarkets
  class Model
    attr_reader :attributes

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

    def ==(other)
      attributes == other.attributes
    end

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

      def attribute(name, options = {})
        name = name.to_sym

        define_attribute_reader name
        define_attribute_writer name, options

        self.defined_attributes ||= []
        self.defined_attributes << name
      end

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

        raise ArgumentError, "Invalid boolean value: #{value}"
      end

      def typecaster_date_time(value, options)
        raise ArgumentError, 'Invalid or missing date time format' unless options[:format].is_a? String

        if value.is_a? String
          begin
            DateTime.strptime(value, options[:format])
          rescue ArgumentError
            raise ArgumentError, "Failed parsing date '#{value}' with format '#{options[:format]}'"
          end
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
