describe IGMarkets::CLI::CursesWindow do
  class Curses
    A_NORMAL = 0

    def self.color_pair(_)
    end

    class Window
      def attron(_); end

      def setpos(_, _); end

      def <<(_); end

      def clear; end

      def refresh; end
    end
  end

  it 'checks for the curses gem' do
    expect(IGMarkets::CLI::CursesWindow).to receive(:require).and_raise(LoadError)
    expect(IGMarkets::CLI::CursesWindow.available?).to be false

    expect(IGMarkets::CLI::CursesWindow).to receive(:require)
    expect(IGMarkets::CLI::CursesWindow.available?).to be true
  end

  it 'prepares curses' do
    expect(IGMarkets::CLI::CursesWindow).to receive(:require)
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

  context do
    let(:curses_window) { instance_double 'Curses::Window' }

    let(:window) do
      expect(IGMarkets::CLI::CursesWindow).to receive(:prepare)
      expect(Curses::Window).to receive(:new).and_return(curses_window)

      IGMarkets::CLI::CursesWindow.new
    end

    it 'clears its contents' do
      expect(curses_window).to receive(:clear)
      window.clear
    end

    it 'refreshes its contents' do
      expect(curses_window).to receive(:refresh)
      window.refresh
    end

    it 'prints lines with colors' do
      expect(curses_window).to receive(:attron)
      expect(curses_window).to receive(:setpos).with(0, 0)
      expect(curses_window).to receive(:<<).with('a')
      expect(curses_window).to receive(:attron)
      expect(curses_window).to receive(:setpos).with(1, 0)
      expect(curses_window).to receive(:<<).with('b')
      expect(curses_window).to receive(:attron)
      expect(curses_window).to receive(:setpos).with(2, 0)
      expect(curses_window).to receive(:<<).with('c')

      window.print_lines ['a', 'b'.red, 'c']
    end
  end
end
