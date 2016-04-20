module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::WorkingOrder} instances in a table.
    class WorkingOrdersTable < Table
      private

      def default_title
        'Working orders'
      end

      def headings
        ['Deal ID', 'EPIC', 'Direction', 'Size', 'Level', 'Limit distance', 'Stop distance', 'Good till date']
      end

      def right_aligned_columns
        [3, 4, 5, 6]
      end

      def row(working_order)
        [
          working_order.deal_id,
          working_order.epic,
          working_order.direction.to_s.capitalize,
          working_order.order_size,
          working_order.order_level,
          working_order.limit_distance,
          working_order.stop_distance,
          (working_order.good_till_date ? working_order.good_till_date.strftime('%F %R %z') : '')
        ]
      end
    end
  end
end
