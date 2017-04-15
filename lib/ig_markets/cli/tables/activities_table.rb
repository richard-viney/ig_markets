module IGMarkets
  module CLI
    module Tables
      # Helper class that prints out an array of {IGMarkets::Activity} instances in a table.
      class ActivitiesTable < Table
        private

        def default_title
          'Activities'
        end

        def headings
          %w[Date Channel Type Status EPIC Market Size Level Limit Stop Result]
        end

        def right_aligned_columns
          [6, 7, 8, 9]
        end

        def row(activity)
          details = activity.details

          [activity.date, activity.channel, activity.type, activity.status, activity.epic, details.market_name,
           details.size, details.level, details.limit_level, details.stop_level, action_types(details)]
        end

        def action_types(details)
          types = details.actions.map(&:action_type).uniq
          types.delete :unknown

          types.map { |v| format_cell_value v }.join ', '
        end
      end
    end
  end
end
