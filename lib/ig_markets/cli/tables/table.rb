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

      def table
        Terminal::Table.new(title: @title, headings: headings, rows: rows).tap do |t|
          Array(right_aligned_columns).each do |column|
            t.align_column column, :right
          end
        end
      end

      def rows
        @models.map do |model|
          row(model).map do |content|
            format_cell content
          end
        end
      end

      def format_cell(content)
        if content.is_a? Float
          format '%g', content
        else
          content
        end
      end
    end
  end
end
