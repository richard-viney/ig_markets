module IGMarkets
  # Contains details on a tradeable instrument. Returned by {Market#instrument}.
  class Instrument < Model
    # Contains details on a currency used by an instrument. Returned by {#currencies}.
    class Currency < Model
      attribute :base_exchange_rate, Float
      attribute :code
      attribute :exchange_rate, Float
      attribute :is_default, Boolean
      attribute :symbol
    end

    # Contains details on the expiry details of an instrument. Returned by {#expiry_details}.
    class ExpiryDetails < Model
      attribute :last_dealing_date, DateTime, format: '%Y/%m/%d %H:%M:%S'
      attribute :settlement_info
    end

    # Contains details on the margin deposit requirements for an instrument at a certain price band. Returned by
    # {#margin_deposit_bands}.
    class MarginDepositBand < Model
      attribute :currency, String, regex: Regex::CURRENCY
      attribute :margin, Float
      attribute :max, Float
      attribute :min, Float
    end

    # Contains details on the opening hours for an instrument. Returned by {#opening_hours}.
    class OpeningHours < Model
      attribute :close_time
      attribute :open_time

      # (See {Model.from}).
      def self.from(value)
        # This check works around a vagary in the IG API where there is a seemingly unnecessary hash for the
        # :opening_hours value that only has a single :market_times key which is what holds the actual data.
        if value.is_a?(Hash) && value.keys == [:market_times]
          super value[:market_times]
        else
          super
        end
      end
    end

    # Contains details on the rollover setup for an instrument. Returned by {#rollover_details}.
    class RolloverDetails < Model
      attribute :last_rollover_time
      attribute :rollover_info
    end

    # Contains details on the slippage factor for an instrument. Returned by {#slippage_factor}.
    class SlippageFactor < Model
      attribute :unit
      attribute :value, Float
    end

    attribute :chart_code
    attribute :contract_size
    attribute :controlled_risk_allowed, Boolean
    attribute :country
    attribute :currencies, Currency
    attribute :epic, String, regex: Regex::EPIC
    attribute :expiry, DateTime, nil_if: '-', format: '%d-%b-%y'
    attribute :expiry_details, ExpiryDetails
    attribute :force_open_allowed, Boolean
    attribute :lot_size, Float
    attribute :margin_deposit_bands, MarginDepositBand
    attribute :margin_factor, Float
    attribute :margin_factor_unit, Symbol, allowed_values: [:percentage, :points]
    attribute :market_id
    attribute :name
    attribute :news_code
    attribute :one_pip_means
    attribute :opening_hours, OpeningHours
    attribute :rollover_details, RolloverDetails
    attribute :slippage_factor, SlippageFactor
    attribute :special_info
    attribute :sprint_markets_maximum_expiry_time, Float
    attribute :sprint_markets_minimum_expiry_time, Float
    attribute :stops_limits_allowed, Boolean
    attribute :streaming_prices_available, Boolean
    attribute :type, Symbol, allowed_values: [
      :binary, :bungee_capped, :bungee_commodities, :bungee_currencies, :bungee_indices, :commodities,
      :currencies, :indices, :opt_commodities, :opt_currencies, :opt_indices, :opt_rates, :opt_shares,
      :rates, :sectors, :shares, :sprint_market, :test_market, :unknown]
    attribute :unit, Symbol, allowed_values: [:amount, :contracts, :shares]
    attribute :value_of_one_pip
  end
end
