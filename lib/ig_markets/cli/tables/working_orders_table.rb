module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::WorkingOrder} instances in a table.
    class WorkingOrdersTable < Table
      private

      def default_title
        'Working orders'
      end

      def headings
        ['Created date', 'EPIC', 'Currency', 'Type', 'Direction', 'Size', 'Level', 'Limit distance', 'Stop distance',
         'Good till date', 'Deal ID']
      end

      def right_aligned_columns
        [5, 6, 7, 8]
      end

      def row(working_order)
        [working_order.created_date_utc, working_order.epic, working_order.currency_code, working_order.order_type,
         working_order.direction, working_order.order_size, Format.level(working_order.order_level),
         working_order.limit_distance, working_order.stop_distance, working_order.good_till_date, working_order.deal_id]
      end
    end
  end
end
