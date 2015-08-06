module IGMarkets
  class Model
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = {}
      attributes.each { |name, value| send("#{name}=", value) }
    end

    def ==(other)
      attributes == other.attributes
    end

    class << self
      def attribute(name, options = {})
        name = name.to_sym

        define_attribute_reader name
        define_attribute_writer name, options
      end

      def from(source)
        source.is_a?(Hash) ? new(source) : source
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
          if type
            send_args = [type, value]
            send_args << options if AttributeTypecasters.method(type).arity == 2

            value = AttributeTypecasters.send(*send_args)
          end

          @attributes[name] = value
        end
      end
    end
  end
end
