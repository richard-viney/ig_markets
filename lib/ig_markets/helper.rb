module IGMarkets
  module Helper
    def format_date(d)
      d.strftime('%d-%m-%Y')
    end

    def format_date_time(dt)
      dt.strftime('%Y:%m:%d-%H:%M:%S')
    end

    module_function :format_date, :format_date_time
  end
end
