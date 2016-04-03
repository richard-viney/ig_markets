module IGMarkets
  class DealingPlatform
    # Provides methods for interacting with sprint market positions. Returned by
    # {DealingPlatform#sprint_market_positions}.
    class SprintMarketPositionMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
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
