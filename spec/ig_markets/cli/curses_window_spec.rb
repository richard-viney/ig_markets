describe IGMarkets::CLI::CursesWindow do
  class Curses
    A_NORMAL = 0

    def self.color_pair(_)
    end

    class Window
      def attron(_)
      end

      def setpos(_, _)
      end

      def <<(_)
      end

      def refresh
      end
    end
  end

  it 'checks for the curses gem' do
    expect(Kernel).to receive(:require).and_raise(LoadError)
    expect(IGMarkets::CLI::CursesWindow.available?).to be false

    expect(Kernel).to receive(:require)
    expect(IGMarkets::CLI::CursesWindow.available?).to be true
  end

  it 'prepares curses' do
    expect(Kernel).to receive(:require)
    expect(Curses).to receive(:noecho)
    expect(Curses).to receive(:nonl)
    expect(Curses).to receive(:stdscr) { double 'nodelay=' => nil }
    expect(Curses).to receive(:init_screen)
    expect(Curses).to receive(:start_color)

    8.times do |index|
      expect(Curses).to receive(:init_pair).with(30 + index, index, 0)
    end

    IGMarkets::CLI::CursesWindow.prepare
  end

  it 'prints tables with colors' do
    curses_window = instance_double 'Curses::Window'

    expect(IGMarkets::CLI::CursesWindow).to receive(:prepare)
    expect(Curses::Window).to receive(:new).and_return(curses_window)

    expect(curses_window).to receive(:attron)
    expect(curses_window).to receive(:setpos).with(0, 0)
    expect(curses_window).to receive(:<<).with('a')
    expect(curses_window).to receive(:attron)
    expect(curses_window).to receive(:setpos).with(1, 0)
    expect(curses_window).to receive(:<<).with('b')
    expect(curses_window).to receive(:attron)
    expect(curses_window).to receive(:setpos).with(2, 0)
    expect(curses_window).to receive(:<<).with('c')
    expect(curses_window).to receive(:setpos).with(4, 0)
    expect(curses_window).to receive(:<<).with('d')
    expect(curses_window).to receive(:refresh)

    IGMarkets::CLI::CursesWindow.new.print_tables "a\n#{'b'.red}\nc", "d"
  end
end
