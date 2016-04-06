module IGMarkets
  module CLI
    # Implements the `ig_markets confirmation` command.
    class Main < Thor
      desc 'confirmation', 'Prints the deal confirmation for the specified deal reference.'

      option :deal_reference, aliases: '-r', required: true, desc: 'The deal reference to print the confirmation for.'

      def confirmation
        begin_session do
          deal_confirmation = dealing_platform.deal_confirmation options[:deal_reference]

          print_deal_confirmation deal_confirmation
        end
      end

      private

      def print_deal_confirmation(deal_confirmation)
        print "#{deal_confirmation.deal_id}: #{deal_confirmation.deal_status}, "

        if deal_confirmation.deal_status == :accepted
          print "affected deals: #{deal_confirmation.affected_deals.map(&:deal_id).join(',')}, "
        else
          print "reason: #{deal_confirmation.reason}, "
        end

        print "epic: #{deal_confirmation.epic}\n"
      end
    end
  end
end
