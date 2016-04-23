module IGMarkets
  module CLI
    # Implements the `ig_markets positions` command.
    class Positions < Thor
      desc 'list', 'Prints open non-binary positions'

      option :aggregate, type: :boolean, desc: 'Whether to aggregate separate positions in the same market'

      def list
        Main.begin_session(options) do |dealing_platform|
          positions = dealing_platform.positions.all.reject do |position|
            position.market.instrument_type == :binary
          end

          positions_table = PositionsTable.new positions, aggregate: options[:aggregate]

          puts positions_table

          print_position_totals positions
        end
      end

      default_task :list

      desc 'create', 'Creates a new position'

      option :currency_code, required: true, desc: 'The 3 character currency code, must be one of the instrument\'s ' \
                                                   'currencies'
      option :direction, required: true, enum: %w(buy sell), desc: 'The trade direction'
      option :epic, required: true, desc: 'The EPIC of the market to trade'
      option :expiry, desc: 'The expiry date of the instrument (if applicable), format: yyyy-mm-dd'
      option :force_open, type: :boolean, default: false, desc: 'Whether a force open is required'
      option :guaranteed_stop, type: :boolean, default: false, desc: 'Whether a guaranteed stop is required'
      option :level, type: :numeric, desc: 'Required if and only if --order-type is \'limit\' or \'quote\''
      option :limit_distance, type: :numeric, desc: 'The distance away in pips to place the limit, if set then ' \
                                                    '--limit-level must not be used'
      option :limit_level, type: :numeric, desc: 'The limit level, if set then --limit-distance must not be used'
      option :order_type, enum: %w(limit market quote), default: 'market', desc: 'The order type'
      option :quote_id, desc: 'The Lightstreamer quote ID, required when using --order-type=quote'
      option :size, type: :numeric, required: true, desc: 'The size of the position'
      option :stop_distance, type: :numeric, desc: 'The distance away in pips to place the stop, if set then ' \
                                                   '--stop-level must not be used'
      option :stop_level, type: :numeric, desc: 'The stop level, if set then --stop-distance must not be used'
      option :time_in_force, enum: %w(execute_and_eliminate fill_or_kill), desc: 'The order fill strategy'
      option :trailing_stop, type: :boolean, desc: 'Whether to use a trailing stop, defaults to false'
      option :trailing_stop_increment, type: :numeric, desc: 'The increment step in pips for the trailing stop, ' \
                                                             'required when --trailing-stop is specified'

      def create
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.positions.create position_attributes

          Main.report_deal_confirmation deal_reference
        end
      end

      desc 'update DEAL-ID', 'Updates attributes of an existing position'

      option :limit_level, desc: 'The limit level'
      option :stop_level, desc: 'The stop level'
      option :trailing_stop, type: :boolean, desc: 'Whether to use a trailing stop, defaults to false'
      option :trailing_stop_distance, type: :numeric, desc: 'The distance away in pips to place the trailing stop'
      option :trailing_stop_increment, type: :numeric, desc: 'The increment step in pips for the trailing stop'

      def update(deal_id)
        with_position(deal_id) do |position|
          position.update position_attributes
        end
      end

      desc 'close DEAL-ID', 'Closes or partially closes a position'

      option :level, type: :numeric, desc: 'Required if and only if --order-type is \'limit\' or \'quote\''
      option :order_type, enum: %w(limit market quote), default: 'market', desc: 'The order type'
      option :quote_id, desc: 'The Lightstreamer quote ID, required when using --order-type=quote'
      option :size, type: :numeric, desc: 'The size of the position to close, if not specified then the entire ' \
                                          'position will be closed'
      option :time_in_force, enum: %w(execute_and_eliminate fill_or_kill), desc: 'The order fill strategy'

      def close(deal_id)
        with_position(deal_id) do |position|
          position.close position_attributes
        end
      end

      private

      ATTRIBUTES = [:currency_code, :direction, :epic, :expiry, :force_open, :guaranteed_stop, :level, :limit_distance,
                    :limit_level, :order_type, :quote_id, :size, :stop_distance, :stop_level, :time_in_force,
                    :trailing_stop, :trailing_stop_increment].freeze

      def position_attributes
        attributes = Main.filter_options options, ATTRIBUTES

        Main.parse_date_time attributes, :expiry, Date, '%F', 'yyyy-mm-dd'

        attributes
      end

      def with_position(deal_id)
        Main.begin_session(options) do |dealing_platform|
          position = dealing_platform.positions[deal_id]

          raise 'no position with the specified ID' unless position

          deal_reference = yield position

          Main.report_deal_confirmation deal_reference
        end
      end

      def print_position_totals(positions)
        currency_totals = positions.group_by(&:currency).map do |currency, subset|
          total = subset.map(&:profit_loss).reduce(:+)

          Format.currency(total, currency).colorize(total < 0 ? :red : :green)
        end

        puts "\nTotal profit/loss: #{currency_totals.join ', '}"
      end
    end
  end
end
