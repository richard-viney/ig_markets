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
        result = @dealing_platform.session.get('positions/sprintmarkets', API_V2).fetch :sprint_market_positions

        @dealing_platform.instantiate_models SprintMarketPosition, result
      end

      # Returns the sprint market position with the specified deal ID, or `nil` if there is no sprint market position
      # with that ID.
      #
      # @param [String] deal_id The deal ID of the sprint market position to return.
      #
      # @return [SprintMarketPosition]
      def [](deal_id)
        all.detect do |sprint_market_position|
          sprint_market_position.deal_id == deal_id
        end
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
        body = RequestBodyFormatter.format SprintMarketPositionCreateAttributes.new(attributes)

        @dealing_platform.session.post('positions/sprintmarkets', body).fetch :deal_reference
      end

      # Internal model used by {#create}
      class SprintMarketPositionCreateAttributes < Model
        attribute :direction, Symbol, allowed_values: [:buy, :sell]
        attribute :epic, String, regex: Regex::EPIC
        attribute :expiry_period, Symbol, allowed_values: [:one_minute, :two_minutes, :five_minutes, :twenty_minutes,
                                                           :sixty_minutes]
        attribute :size, Float
      end

      private_constant :SprintMarketPositionCreateAttributes
    end
  end
end
