module IGMarkets
  module CLI
    # Implements the `ig_markets positions` command.
    class Main
      desc 'positions', 'Prints open positions'

      def positions
        begin_session do
          dealing_platform.positions.all.each do |position|
            print <<-END
#{position.deal_id}: \
#{position.formatted_size} of #{position.market.epic} at #{position.level}, \
profit/loss: #{Format.currency position.profit_loss, position.currency}
END
          end
        end
      end
    end
  end
end
