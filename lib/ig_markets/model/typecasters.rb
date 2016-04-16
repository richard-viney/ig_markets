module IGMarkets
  # Implement typecaster methods for Model.
  class Model
    class << self
      private

      def typecaster_for(type)
        if [Boolean, String, Fixnum, Float, Symbol, Date, Time].include? type
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
        return nil if value.nil?

        value.to_s.to_i
      end

      def typecaster_float(value, _options)
        return nil if value.nil?

        Float(value)
      end

      def typecaster_symbol(value, _options)
        return nil if value.nil?

        value.to_s.downcase.to_sym
      end

      def typecaster_date(value, options)
        raise ArgumentError, "#{self}: invalid or missing date format" unless options[:format].is_a? String

        if value.is_a? String
          begin
            Date.strptime value, options[:format]
          rescue ArgumentError
            raise ArgumentError, "#{self}: failed parsing date '#{value}' with format '#{options[:format]}'"
          end
        else
          value
        end
      end

      def typecaster_time(value, options)
        raise ArgumentError, "#{self}: invalid or missing time format" unless options[:format].is_a? String

        if value.is_a?(String) || value.is_a?(Fixnum)
          parse_time_from_string value.to_s, options
        else
          value
        end
      end

      def parse_time_from_string(value, options)
        format = options[:format]
        time_zone = options[:time_zone]

        time_zone ||= '+0000' unless format == '%Q'

        begin
          Time.strptime "#{value}#{time_zone}", "#{format}#{'%z' if time_zone}"
        rescue ArgumentError
          raise ArgumentError, "#{self}: failed parsing time '#{value}' with format '#{format}'"
        end
      end
    end
  end
end
