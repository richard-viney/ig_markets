module IGMarkets
  module CLI
    # Implements the `ig_markets orders` command.
    class Main
      desc 'orders', 'Prints working orders'

      def orders
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.working_orders.all.each do |order|
            Output.print_working_order order
          end
        end
      end
    end
  end
end
