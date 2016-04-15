module IGMarkets
  module CLI
    # Implements the `ig_markets sprints` command.
    class Sprints < Thor
      desc 'list', 'Prints open sprint market positions'

      def list
        Main.begin_session(options) do |dealing_platform|
          dealing_platform.sprint_market_positions.all.each do |sprint_market_position|
            Output.print_sprint_market_position sprint_market_position
          end
        end
      end

      default_task :list

      desc 'create', 'Creates a new sprint market position'

      option :direction, required: true, desc: 'The direction of the new sprint market position'
      option :epic, required: true, desc: 'The EPIC of the market for the new sprint market position'
      option :expiry_period, required: true, desc: 'The expiry period in seconds of the new sprint market position'
      option :size, required: true, desc: 'The size of the new sprint market position'

      def create
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.sprint_market_positions.create new_sprint_market_position_attributes

          puts "Deal reference: #{deal_reference}"

          Output.print_deal_confirmation dealing_platform.deal_confirmation deal_reference
        end
      end

      private

      def new_sprint_market_position_attributes
        {
          direction: options[:direction],
          epic: options[:epic],
          expiry_period: expiry_period,
          size: options[:size]
        }
      end

      def expiry_period
        {
          '1' => :one_minute,
          '2' => :two_minutes,
          '5' => :five_minutes,
          '20' => :twenty_minutes,
          '60' => :sixty_minutes
        }.fetch options[:expiry_period]
      end
    end
  end
end
