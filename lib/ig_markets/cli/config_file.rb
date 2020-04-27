module IGMarkets
  module CLI
    # Helper class for working with the YAML config files supported by the command-line client. A config file has a
    # `profiles` root key and every subkey of this root key specifies the name of a profile. The values underneath each
    # subkey are then interpreted as command-line arguments. The profile to use is chosen using the `--profiles`
    # command-line argument.
    #
    # See `README.md` for further details.
    class ConfigFile
      # Initializes this config file with the passed content.
      #
      # @param [Hash] content
      def initialize(content = {})
        @content = content || {}

        @profiles = (@content['profiles'] || {}).transform_values do |profile_arguments|
          profile_arguments.map do |argument, value|
            "--#{argument}=#{value}"
          end
        end
      end

      # Inserts the arguments specified in this config file into the passed arguments array.
      #
      # @param [Array<String>] argv The array of command-line arguments to alter.
      def prepend_profile_arguments_to_argv(argv)
        profile = selected_profile argv

        insert_index = argv.index do |argument|
          argument[0] == '-'
        end || -1

        argv.insert insert_index, *@profiles.fetch(profile, [])
      end

      # Takes a list of potential config files and returns a {ConfigFile} instance for the first one that exists.
      #
      # @return [ConfigFile]
      def self.find(*config_files)
        config_file = config_files.detect do |filename|
          File.exist? filename
        end

        new(config_file && YAML.load_file(config_file))
      end

      private

      # Searches the passed arguments list for the name of the profile to use (specified by the `--profile` argument).
      def selected_profile(argv)
        profile_index = argv.index '--profile'

        if profile_index
          argv.delete_at profile_index
          argv.delete_at profile_index
        else
          'default'
        end
      end
    end
  end
end
