module IGMarkets
  module CLI
    # This class supports the display of a {Table} with live updates using a fullscreen curses window.
    #
    # @private
    class CursesWindow
      # Initializes this fullscreen curses window.
      def initialize
        self.class.prepare

        @window = Curses::Window.new 0, 0, 0, 0
      end

      # Prints the specified tables in this fullscreen curses window,
      #
      # @param [Array<Table>] tables The tables to display.
      def print_tables(*tables)
        change_foreground_color nil

        offset = 0

        tables.each do  |table|
          table_lines = table.to_s.split "\n"

          table_lines.each_with_index do |line, index|
            @position = [offset + index, 0]
            print_next_line_segment line until line.empty?
          end

          offset += table_lines.size + 1
        end

        @window.refresh
      end

      private

      class << self
        # Returns whether curses support is available. On Windows the 'curses' gem is optional and so this class may not
        # be usable.
        def available?
          Kernel.require 'curses'
          true
        rescue LoadError
          false
        end

        def prepare
          raise 'Curses gem is not installed' unless available?

          return if @prepared

          Curses.noecho
          Curses.nonl
          Curses.stdscr.nodelay = 1
          Curses.init_screen
          Curses.start_color

          8.times { |color| Curses.init_pair (30 + color), color, 0 }

          @prepared = true
        end
      end

      COLORIZE_REGEXP = /^\e\[0(?:;(\d+);49)?m/

      def print_next_line_segment(line)
        match = line.match COLORIZE_REGEXP

        if match
          change_foreground_color match.captures.first
          line[/^[^m]+m/] = ''
        else
          print_character line[0]
          line[0] = ''
        end
      end

      def change_foreground_color(colorize_number)
        colorize_number ||= 37

        @window.attron Curses.color_pair(colorize_number.to_i) | Curses::A_NORMAL
      end

      def print_character(character)
        @window.setpos @position[0], @position[1]
        @window << character
        @position[1] += 1
      end
    end
  end
end
