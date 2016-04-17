module IGMarkets
  module CLI
    # Implements the `ig_markets positions` command.
    class Positions < Thor
      desc 'list', 'Prints open positions'

      def list
        Main.begin_session(options) do |dealing_platform|
          dealing_platform.positions.all.each do |position|
            Output.print_position position
          end
        end
      end

      default_task :list

      desc 'create', 'Creates a new position'

      option :currency_code, required: true, desc: 'The 3 character currency code, must be one of the instrument\'s ' \
                                                   'currencies'
      option :direction, required: true, desc: 'The trade direction, must be \'buy\' or \'sell\''
      option :epic, required: true, desc: 'The EPIC of the market to trade'
      option :expiry, desc: 'The expiry date of the instrument (if applicable), format: yyyy-mm-dd'
      option :force_open, type: :boolean, default: false, desc: 'Whether a force open is required'
      option :guaranteed_stop, type: :boolean, default: false, desc: 'Whether a guaranteed stop is required'
      option :level, type: :numeric, desc: 'Required if and only if --order-type is \'limit\' or \'quote\''
      option :limit_distance, type: :numeric, desc: 'The distance away in pips to place the limit, if set then ' \
                                                    '--limit-level must not be used'
      option :limit_level, type: :numeric, desc: 'The limit level, if set then --limit-distance must not be used'
      option :order_type, default: 'market', desc: 'The order type, must be \'limit\', \'market\' or \'quote\''
      option :quote_id, desc: 'The Lightstreamer quote ID, required when using --order-type=quote'
      option :size, type: :numeric, required: true, desc: 'The size of the position'
      option :stop_distance, type: :numeric, desc: 'The distance away in pips to place the stop, if set then ' \
                                                   '--stop-level must not be used'
      option :stop_level, type: :numeric, desc: 'The stop level, if set then --stop-distance must not be used'
      option :time_in_force, desc: 'The order fill strategy, either \'execute_and_eliminate\' or \'fill_or_kill\''
      option :trailing_stop, type: :boolean, desc: 'Whether to use a trailing stop, defaults to false'
      option :trailing_stop_increment, type: :numeric, desc: 'The increment step in pips for the trailing stop, ' \
                                                             'required when --trailing-stop is specified'

      def create
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.positions.create position_attributes

          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation(deal_reference)
        end
      end

      desc 'update <DEAL-ID>', 'Updates attributes of an existing position'

      option :limit_level, type: :numeric, desc: 'The limit level'
      option :stop_level, type: :numeric, desc: 'The stop level'
      option :trailing_stop, type: :boolean, desc: 'Whether to use a trailing stop, defaults to false'
      option :trailing_stop_distance, type: :numeric, desc: 'The distance away in pips to place the trailing stop'
      option :trailing_stop_increment, type: :numeric, desc: 'The increment step in pips for the trailing stop'

      def update(deal_id)
        with_position(deal_id) do |position|
          position.update position_attributes
        end
      end

      desc 'close <DEAL-ID>', 'Closes or partially closes a position'

      option :level, type: :numeric, desc: 'Required if and only if --order-type is \'limit\' or \'quote\''
      option :order_type, default: 'market', desc: 'The order type, must be \'limit\', \'market\' or \'quote\''
      option :quote_id, desc: 'The Lightstreamer quote ID, required when using --order-type=quote'
      option :size, type: :numeric, desc: 'The size of the position to close, if not specified then the entire ' \
                                          'position will be closed'
      option :time_in_force, desc: 'The order fill strategy, either \'execute_and_eliminate\' or \'fill_or_kill\''

      def close(deal_id)
        with_position(deal_id) do |position|
          position.close position_attributes
        end
      end

      private

      def position_attributes
        attributes = options.each_with_object({}) do |(key, value), new_hash|
          next unless [:currency_code, :direction, :epic, :expiry, :force_open, :guaranteed_stop, :level,
                       :limit_distance, :limit_level, :order_type, :quote_id, :size, :stop_distance, :stop_level,
                       :time_in_force, :trailing_stop, :trailing_stop_increment].include? key.to_sym

          new_hash[key.to_sym] = value
        end

        Main.parse_date_time attributes, :expiry, Date, '%F', 'yyyy-mm-dd'

        attributes
      end

      def with_position(deal_id)
        Main.begin_session(options) do |dealing_platform|
          position = dealing_platform.positions[deal_id]

          raise 'no position with the specified ID' unless position

          deal_reference = yield position

          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation(deal_reference)
        end
      end
    end
  end
end
