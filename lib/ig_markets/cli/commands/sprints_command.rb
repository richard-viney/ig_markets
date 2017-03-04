module IGMarkets
  module CLI
    # Implements the `ig_markets sprints` command.
    class Sprints < Thor
      desc 'list', 'Prints open sprint market positions'

      def list
        Main.begin_session(options) do |dealing_platform|
          sprints = dealing_platform.sprint_market_positions.all

          markets = dealing_platform.markets.find sprints.map(&:epic).uniq

          table = Tables::SprintMarketPositionsTable.new sprints, markets: markets

          puts table
        end
      end

      default_task :list

      desc 'create', 'Creates a new sprint market position'

      option :direction, enum: %w(buy sell), required: true, desc: 'The trade direction'
      option :epic, required: true, desc: 'The EPIC of the market to trade'
      option :expiry_period, enum: %w(1 2 5 20 60), required: true, desc: 'The expiry period in seconds'
      option :size, required: true, desc: 'The position size'

      def create
        Main.begin_session(options) do |dealing_platform|
          deal_reference = dealing_platform.sprint_market_positions.create sprint_market_position_attributes

          Main.report_deal_confirmation deal_reference
        end
      end

      private

      def sprint_market_position_attributes
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
