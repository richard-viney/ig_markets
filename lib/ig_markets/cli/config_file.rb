module IGMarkets
  module CLI
    # Helper class for working with the config files supported by the command-line client.
    class ConfigFile
      # Initializes this config file with the passed lines.
      #
      # @param [Array<String>] lines
      def initialize(lines = [])
        @lines = lines
      end

      # Returns the arguments contained in this config file.
      #
      # @return [Array<String>]
      def arguments
        @lines.map { |line| line.gsub(/#.*/, '') }
              .map(&:strip)
              .join(' ')
              .split(' ')
      end

      # Inserts the arguments from this config file into the passed arguments array.
      #
      # @param [Array<String>] argv The array of command-line arguments to alter.
      def prepend_arguments_to_argv(argv)
        insert_index = argv.index do |argument|
          argument[0] == '-'
        end || -1

        argv.insert insert_index, *arguments
      end

      # Takes a list of potential config files and returns a {ConfigFile} instance for the first one that exists.
      #
      # @return [ConfigFile]
      def self.find(*config_files)
        config_file = config_files.detect do |filename|
          File.exist? filename
        end

        new(config_file ? File.readlines(config_file) : [])
      end
    end
  end
end
