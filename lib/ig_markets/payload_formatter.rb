module IGMarkets
  # Contains methods for formatting payloads that can be passed to the IG Markets API.
  module PayloadFormatter
    module_function

    # Takes a {Model} and returns its attributes in a hash ready to be passed as a payload to the IG Markets API.
    # Attribute names will be converted to use camel case rather than snake case, `Symbol` attributes will be converted
    # to strings and be uppercased, and `DateTime` attributes will be converted to strings using their ':format' option.
    #
    # @param [Model] model The model instance to convert attributes for.
    #
    # @return [Hash] The resulting attributes hash.
    def format(model)
      model.class.defined_attributes.each_with_object({}) do |(name, options), formatted|
        value = model.send name

        if value
          value = value.to_s.upcase if options[:type] == Symbol
          value = value.strftime(options.fetch(:format)) if options[:type] == DateTime
        end

        formatted[snake_case_to_camel_case(name).to_sym] = value
      end
    end

    # Takes a string or symbol that uses snake case and converts it to camel case.
    #
    # @param [String, Symbol] value The string or symbol to convert to camel case
    #
    # @return [String] The camel case version of `value`.
    def snake_case_to_camel_case(value)
      pieces = value.to_s.split '_'

      pieces[0] + pieces[1..-1].map(&:capitalize).join
    end
  end
end
