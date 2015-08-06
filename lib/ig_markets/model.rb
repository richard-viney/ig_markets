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

        define_method name do
          @attributes[name]
        end

        define_method "#{name}=" do |value|
          value = AttributeTypecasters.send(options[:type], value, options) if options.key? :type

          @attributes[name] = value
        end
      end

      def from(source)
        source.is_a?(Hash) ? new(source) : source
      end
    end
  end
end
