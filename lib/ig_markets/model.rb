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

      def apply_typecaster(type, value, options)
        send_args = [type, value]
        send_args << options if AttributeTypecasters.method(type).arity == 2

        AttributeTypecasters.send(*send_args)
      end

      def from(source)
        if source.nil?
          nil
        elsif source.is_a? Hash
          new source
        elsif source.is_a? self
          source.dup
        else
          fail ArgumentError, "Unable to make a #{self} from instance of #{source.class}"
        end
      end

      private

      def define_attribute_reader(name)
        define_method name do
          @attributes[name]
        end
      end

      def define_attribute_writer(name, options)
        type = options.delete :type

        define_method "#{name}=" do |value|
          value = self.class.apply_typecaster(type, value, options) if type

          @attributes[name] = value
        end
      end
    end
  end
end
