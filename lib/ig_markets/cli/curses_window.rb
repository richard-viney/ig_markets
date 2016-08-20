module IGMarkets
  module CLI
    # This helper class supports the display of text in a fullscreen curses window.
    #
    # @private
    class CursesWindow
      # Initializes this fullscreen curses window.
      def initialize
        self.class.prepare

        @window = Curses::Window.new 0, 0, 0, 0
        @position = [0, 0]
      end

      # Clears the contents of this curses window and resets the cursor to the top left.
      def clear
        @window.clear
        @position = [0, 0]
      end

      # Refreshes this curses window so its content is updated on the screen.
      def refresh
        @window.refresh
      end

      # Prints the specified lines in this fullscreen curses window.
      #
      # @param [Array<String>] lines The lines to print.
      def print_lines(*lines)
        change_foreground_color nil

        lines.flatten.each do |line|
          print_next_line_segment line until line.empty?

          @position[0] += 1
          @position[1] = 0
        end
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
          raise IGMarketsError, 'curses gem is not installed' unless available?

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
