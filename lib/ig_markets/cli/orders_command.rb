module IGMarkets
  module CLI
    # Implements the `ig_markets orders` command.
    class Orders < Thor
      desc 'list', 'Prints working orders'

      def list
        Main.begin_session(options) do |dealing_platform|
          dealing_platform.working_orders.all.each do |order|
            Output.print_working_order order
          end
        end
      end

      default_task :list

      desc 'create', 'Creates a new working order'

      option :currency_code, required: true, desc: 'The 3 character currency code, must be one of the instrument\'s ' \
                                                   'currencies'
      option :direction, required: true, desc: 'The trade direction, must be \'buy\' or \'sell\''
      option :epic, required: true, desc: 'The EPIC of the market to trade'
      option :expiry, desc: 'The expiry date of the instrument (if applicable), format: yyyy-mm-dd'
      option :force_open, type: :boolean, default: false, desc: 'Whether a force open is required, default: false'
      option :good_till_date, desc: 'The date that the order will live till, if not specified then the order will ' \
                                    'remain until it is deleted, format: yyyy-mm-ddThh:mm(+|-)zz:zz'
      option :guaranteed_stop, type: :boolean, default: false, desc: 'Whether a guaranteed stop is required, ' \
                                                                     'default: false'
      option :level, type: :numeric, required: true, desc: 'The level at which the order will be triggered'
      option :limit_distance, type: :numeric, desc: 'The distance away in pips to place the limit'
      option :size, type: :numeric, required: true, desc: 'The size of the order'
      option :stop_distance, type: :numeric, desc: 'The distance away in pips to place the stop'
      option :type, required: true, desc: 'The order type, either \'limit\' or \'stop\''

      def create
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.working_orders.create working_order_attributes

          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation(deal_reference)
        end
      end

      desc 'update <DEAL-ID>', 'Updates an existing working order'

      option :good_till_date, desc: 'The date that the order will live till, if not specified then the order will ' \
                                    'remain until it is deleted, format: yyyy-mm-ddThh:mm(+|-)zz:zz'
      option :level, type: :numeric, desc: 'The level at which the order will be triggered'
      option :limit_distance, type: :numeric, desc: 'The distance away in pips to place the limit'
      option :stop_distance, type: :numeric, desc: 'The distance away in pips to place the stop'
      option :type, desc: 'The order type, either \'limit\' or \'stop\''

      def update(deal_id)
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.working_orders[deal_id].update working_order_attributes

          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation(deal_reference)
        end
      end

      desc 'delete <DEAL-ID>', 'Deletes the working order with the specified deal ID'

      def delete(deal_id)
        Main.begin_session(options) do |dealing_platform|
          working_order = dealing_platform.working_orders[deal_id]

          raise 'No working order with the specified deal ID' unless working_order

          deal_reference = working_order.delete
          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation(deal_reference)
        end
      end

      private

      def working_order_attributes
        attributes = options.each_with_object({}) do |(key, value), new_hash|
          if [:currency_code, :direction, :epic, :expiry, :force_open, :good_till_date, :guaranteed_stop, :level,
              :limit_distance, :size, :stop_distance, :type].include? key.to_sym
            new_hash[key.to_sym] = value
          end
        end

        parse_date_or_time attributes, :expiry, Date, '%F', 'yyyy-mm-dd'
        parse_date_or_time attributes, :good_till_date, Time, '%FT%R%z', 'yyyy-mm-ddThh:mm(+|-)zz:zz'

        attributes
      end

      def parse_date_or_time(attributes, attribute, klass, format, display_format)
        return unless attributes.key? attribute

        if !['', attribute.to_s].include? attributes[attribute].to_s
          begin
            attributes[attribute] = klass.strptime attributes[attribute], format
          rescue ArgumentError
            raise "invalid #{attribute}, use format \"#{display_format}\""
          end
        else
          attributes[attribute] = nil
        end
      end
    end
  end
end
