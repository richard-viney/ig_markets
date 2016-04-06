module IGMarkets
  class DealingPlatform
    # Provides methods for working with sprint market positions. Returned by {DealingPlatform#sprint_market_positions}.
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

      # Creates a new sprint market position.
      #
      # @param [Hash] attributes The attributes for the new sprint market position.
      # @option attributes [String] :epic The EPIC for the instrument to create a sprint market position for. Required.
      # @option attributes [:buy, :sell] :direction The position direction. Required.
      # @option attributes [:one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes] :expiry_period
      #                    The expiry period. Required.
      # @option attributes [Float] :size The size of the sprint market position to create. Required.
      #
      # @return [String] The resulting deal reference, use {DealingPlatform#deal_confirmation} to check the result of
      #         the sprint market position creation.
      def create(attributes)
        payload = PayloadFormatter.format SprintMarketPositionCreateAttributes.new attributes

        @dealing_platform.session.post('positions/sprintmarkets', payload, API_V1).fetch(:deal_reference)
      end

      # Internal model used by {#create}
      class SprintMarketPositionCreateAttributes < Model
        attribute :direction, Symbol, allowed_values: [:buy, :sell]
        attribute :epic, String, regex: Regex::EPIC
        attribute :expiry_period, Symbol, allowed_values: [
          :one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes]
        attribute :size, Fixnum
      end
    end
  end
end
