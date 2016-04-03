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
        @dealing_platform.session.get('positions', API_V2).fetch(:positions).map do |attributes|
          position_from_attributes attributes
        end
      end

      # Returns the position with the specified deal ID.
      #
      # @param [String] deal_id The deal ID of the working order to return.
      #
      # @return [Position] The position with the specified deal ID, or `nil` if there is no position with that ID.
      def [](deal_id)
        attributes = @dealing_platform.session.get "positions/#{deal_id}", API_V2

        position_from_attributes attributes
      end

      private

      def position_from_attributes(attributes)
        Position.new attributes.fetch(:position).merge(market: attributes.fetch(:market))
      end
    end
  end
end
