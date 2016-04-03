module IGMarkets
  class DealingPlatform
    # Provides methods for interacting with positions. Returned by {DealingPlatform#positions}.
    class PositionMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all positions.
      #
      # @return [Array<Position>]
      def all
        @dealing_platform.session.get('positions', API_VERSION_2).fetch(:positions).map do |attributes|
          position_from_attributes attributes
        end
      end

      # Returns the position that has the specified deal ID.
      #
      # @param [String] deal_id The deal ID for the position.
      #
      # @return [Position]
      def [](deal_id)
        attributes = @dealing_platform.session.get "positions/#{deal_id}", API_VERSION_2

        position_from_attributes attributes
      end

      private

      def position_from_attributes(attributes)
        Position.new attributes.fetch(:position).merge(market: attributes.fetch(:market))
      end
    end
  end
end
