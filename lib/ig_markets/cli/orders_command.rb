module IGMarkets
  module CLI
    # Implements the `ig_markets orders` command.
    class Main
      desc 'orders', 'Prints working orders'

      def orders
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.working_orders.all.each do |order|
            print_working_order order
          end
        end
      end

      private

      def print_working_order(order)
        puts <<-END
#{order.deal_id}: \
#{order.direction} #{format '%g', order.order_size} of #{order.epic} at #{order.order_level}\
, limit distance: #{order.limit_distance || '-'}\
, stop distance: #{order.stop_distance || '-'}\
#{", good till #{order.good_till_date.utc.strftime '%F %T %z'}" if order.time_in_force == :good_till_date}
END
      end
    end
  end
end
