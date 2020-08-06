module IGMarkets
  # Implement typecaster methods for Model.
  class Model
    class << self
      private

      def typecaster_for(type)
        if [Boolean, String, Integer, Float, Symbol, Date, Time].include? type
          method "typecaster_#{type.to_s.delete_prefix('IGMarkets::').downcase}"
        elsif type
          lambda do |value, _options, name|
            if Array(value).any? { |entry| !entry.is_a? type }
              raise ArgumentError, "incorrect type set on #{self.name}##{name}: #{value.inspect}"
            end

            value
          end
        end
      end

      def typecaster_boolean(value, _options, name)
        return value if [nil, true, false].include? value
        return value == '1' if %w[0 1].include? value

        raise ArgumentError, "#{self.name}##{name}: invalid boolean value: #{value}"
      end

      def typecaster_string(value, options, name)
        return nil if value.nil?

        if options.key?(:regex) && !options[:regex].match(value.to_s)
          raise ArgumentError, "#{self.name}##{name}: invalid string value: #{value}"
        end

        value.to_s
      end

      def typecaster_integer(value, _options, _name)
        return nil if value.nil?

        value.to_s.to_i
      end

      def typecaster_float(value, _options, name)
        return nil if value.nil? || value == ''

        Float(value)
      rescue ArgumentError
        raise ArgumentError, "#{self.name}##{name}: invalid float value: #{value}"
      end

      def typecaster_symbol(value, _options, _name)
        return nil if value.nil?

        value.to_s.downcase.to_sym
      end

      def typecaster_date(value, options, name)
        if value.is_a? String
          parse_formatted_date_value value, options, name
        else
          value
        end
      end

      def parse_formatted_date_value(value, options, name)
        Array(options[:format]).each do |format|
          return Date.strptime value, format
        rescue ArgumentError
          next
        end

        raise ArgumentError, "#{self.name}##{name}: failed parsing date: #{value}"
      end

      def typecaster_time(value, options, name)
        if value.is_a?(String) || value.is_a?(Integer)
          parse_formatted_time_value value.to_s, options, name
        else
          value
        end
      end

      def parse_formatted_time_value(value, options, name)
        Array(options[:format]).each do |format|
          return parse_time_using_format value, format
        rescue ArgumentError
          next
        end

        raise ArgumentError, "#{self.name}##{name}: failed parsing time: #{value}"
      end

      def parse_time_using_format(value, format)
        unless format == '%Q'
          format += '%z'
          value += '+0000'
        end

        Time.strptime value, format
      end
    end
  end
end
