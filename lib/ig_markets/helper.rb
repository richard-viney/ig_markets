module IGMarkets
  module Helper
    def format_date(d)
      d.strftime('%d-%m-%Y')
    end

    def hash_with_snake_case_keys(hash)
      hash.each_with_object({}) do |(k, v), new_hash|
        new_hash[k.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym] = v
      end
    end

    module_function :format_date, :hash_with_snake_case_keys
  end
end
