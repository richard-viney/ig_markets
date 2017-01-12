# This script is responsible for installing the curses gem on all platforms except Windows.

require 'rubygems/command'
require 'rubygems/dependency_installer'

Gem::Command.build_args = ARGV
Gem::DependencyInstaller.new.install 'curses', '~> 1.0' unless Gem.win_platform?

File.write File.join(File.dirname(__FILE__), 'Rakefile'), 'task :default'
