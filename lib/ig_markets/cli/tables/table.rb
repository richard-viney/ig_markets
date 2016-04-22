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

      def row_color(_model)
      end

      def table
        Terminal::Table.new(title: @title, headings: headings, rows: rows).tap do |t|
          Array(right_aligned_columns).each do |column|
            t.align_column column, :right
          end
        end
      end

      def rows
        @models.flatten.map do |model|
          if model == :separator
            :separator
          else
            color = row_color(model) || :default

            row(model).map do |content|
              color == :default ? format_cell(content) : format_cell(content).colorize(color)
            end
          end
        end
      end

      def format_cell(content)
        if content.is_a? TrueClass
          'Yes'
        elsif content.is_a? FalseClass
          'No'
        elsif content.is_a? Float
          format '%g', content
        else
          content.to_s.strip
        end
      end
    end
  end
end
