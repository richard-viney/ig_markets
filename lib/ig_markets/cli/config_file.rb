module IGMarkets
  module CLI
    # Helper class for working with the config files supported by the command-line client.
    class ConfigFile
      # Initializes this config file with the contents of the specified config file.
      def initialize(config_file)
        @lines = File.readlines config_file
      end

      # Returns the arguments in this config file as an array.
      #
      # @return [Array<String>]
      def arguments
        @lines.map { |line| line.gsub(/#.*/, '') }
              .map(&:strip)
              .join(' ')
              .split(' ')
      end

      # Returns the config file to use, or `nil` if there is no config file.
      #
      # @return [CLI::ConfigFile]
      def self.find
        config_file_locations = [
          "#{Dir.pwd}/.ig_markets",
          "#{Dir.home}/.ig_markets"
        ]

        config_file = config_file_locations.detect do |filename|
          File.exist? filename
        end

        config_file ? new(config_file) : nil
      end
    end
  end
end
