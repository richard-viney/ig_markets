module IGMarkets
  module CLI
    # Implements the `ig_markets confirmation` command.
    class Main < Thor
      desc 'confirmation DEAL-REFERENCE', 'Prints the deal confirmation for the specified deal reference'

      def confirmation(deal_reference)
        self.class.begin_session(options) do |_dealing_platform|
          Main.report_deal_confirmation deal_reference
        end
      end
    end
  end
end
