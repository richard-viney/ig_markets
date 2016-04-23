module IGMarkets
  module CLI
    # Base class with shared table setup and display methods. Used to print output tables in the command-line client.
    class Table
      # Initializer that takes the array of models to display in this table.
      #
      # @param [Array] models The array of models.
      # @param [Hash] options The options hash.
      # @option options [String] :title The title for this table.
      def initialize(models, options = {})
        @models = models
        @title = options[:title] || default_title
      end

      # Converts this table into a formatted string.
      def to_s
        table.to_s
      end

      private

      def default_title
      end

      def headings
      end

      def right_aligned_columns
      end

      def row(_model)
      end

      def cell_color(_value, _model, _row_index, _column_index)
      end

      def table
        Terminal::Table.new(title: @title, headings: headings, rows: rows).tap do |t|
          Array(right_aligned_columns).each do |column|
            t.align_column column, :right
          end
        end
      end

      def rows
        @models.flatten.each_with_index.map do |model, row_index|
          if model == :separator
            :separator
          else
            row(model).flatten.each_with_index.map do |value, column_index|
              cell_content value, model, row_index, column_index
            end
          end
        end
      end

      def cell_content(value, model, row_index, column_index)
        color = cell_color value, model, row_index, column_index

        content = format_cell_value(value).strip

        color ? content.colorize(color) : content
      end

      def format_cell_value(value)
        return format_boolean(value) if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        return format_float(value) if value.is_a? Float
        return format_time(value) if value.is_a? Time
        return format_date(value) if value.is_a? Date

        format_string value
      end

      def format_boolean(value)
        { true => 'Yes', false => 'No' }.fetch value
      end

      def format_float(value)
        format '%g', value
      end

      def format_time(value)
        value.utc.strftime '%F %T %Z'
      end

      def format_date(value)
        value.strftime '%F'
      end

      def format_string(value)
        value = if value.is_a? Symbol
                  value.to_s.tr '_', ' '
                else
                  value.to_s
                end

        return '' if value.empty?

        value[0].upcase + value[1..-1]
      end
    end
  end
end
