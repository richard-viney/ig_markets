module IGMarkets
  # Implement typecaster methods for Model.
  class Model
    class << self
      private

      def typecaster_for(type)
        if [Boolean, String, Fixnum, Float, Symbol, Date, Time].include? type
          method "typecaster_#{type.to_s.gsub(/\AIGMarkets::/, '').downcase}"
        elsif type
          lambda do |value, _options, name|
            if Array(value).any? { |entry| !entry.is_a? type }
              raise ArgumentError, "incorrect type set on #{self}##{name}: #{value.inspect}"
            end

            value
          end
        end
      end

      def typecaster_boolean(value, _options, _name)
        return value if [nil, true, false].include? value

        raise ArgumentError, "#{self}##{name}: invalid boolean value: #{value}"
      end

      def typecaster_string(value, options, _name)
        return nil if value.nil?

        if options.key?(:regex) && !options[:regex].match(value.to_s)
          raise ArgumentError, "#{self}##{name}: invalid string value: #{value}"
        end

        value.to_s
      end

      def typecaster_fixnum(value, _options, _name)
        return nil if value.nil?

        value.to_s.to_i
      end

      def typecaster_float(value, _options, _name)
        return nil if value.nil? || value == ''

        Float(value)
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
          begin
            return Date.strptime value, format
          rescue ArgumentError
            next
          end
        end

        raise ArgumentError, "#{self}##{name}: failed parsing date: #{value}"
      end

      def typecaster_time(value, options, name)
        if value.is_a?(String) || value.is_a?(Fixnum)
          parse_formatted_time_value value.to_s, options, name
        else
          value
        end
      end

      def parse_formatted_time_value(value, options, name)
        Array(options[:format]).each do |format|
          begin
            return parse_time_using_format value, format
          rescue ArgumentError
            next
          end
        end

        raise ArgumentError, "#{self}##{name}: failed parsing time: #{value}"
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
