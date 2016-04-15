module IGMarkets
  module CLI
    # Implements the `ig_markets sprints` command.
    class Main
      desc 'sprints', 'Prints open sprint market positions'

      def sprints
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.sprint_market_positions.all.each do |sprint|
            print_sprint_market_position sprint
          end
        end
      end

      private

      def print_sprint_market_position(sprint)
        puts <<-END
#{sprint.deal_id}: \
#{Format.currency sprint.size, sprint.currency} on #{sprint.epic} \
to be #{{ buy: 'above', sell: 'below' }.fetch(sprint.direction)} #{sprint.strike_level} \
in #{Format.seconds sprint.seconds_till_expiry}, \
payout: #{Format.currency sprint.payout_amount, sprint.currency}
END
      end
    end
  end
end
