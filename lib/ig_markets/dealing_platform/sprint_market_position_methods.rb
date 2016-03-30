module IGMarkets
  class DealingPlatform
    # Helper class that provides methods for interacting with sprint market positions.
    class SprintMarketPositionMethods
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all sprint market positions.
      #
      # @return [Array<SprintMarketPosition>]
      def all
        @dealing_platform.gather 'positions/sprintmarkets', :sprint_market_positions, SprintMarketPosition
      end
    end
  end
end
