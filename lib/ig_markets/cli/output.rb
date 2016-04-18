module IGMarkets
  module CLI
    # Contains methods used by the CLI to print models to stdout.
    module Output
      module_function

      def print_account(account)
        puts <<-END
Account '#{account.account_name}':
  ID:           #{account.account_id}
  Type:         #{account.account_type.to_s.upcase}
  Currency:     #{account.currency}
  Status:       #{account.status.to_s.upcase}
END
      end

      def print_account_balance(account)
        {
          available:   'Available:  ',
          balance:     'Balance:    ',
          deposit:     'Margin:     ',
          profit_loss: 'Profit/loss:'
        }.each do |attribute, title|
          puts "  #{title}  #{Format.currency account.balance.send(attribute), account.currency}"
        end
      end

      def print_activity(activity)
        puts <<-END
#{activity.date.strftime '%F'} #{activity.deal_id}: \
#{activity.size} of #{activity.epic}, \
level: #{activity.level}, \
result: #{activity.result}
END
      end

      def print_client_sentiment(client_sentiment)
        puts <<-END
#{client_sentiment.market_id}: \
longs: #{client_sentiment.long_position_percentage}%, \
shorts: #{client_sentiment.short_position_percentage}%
END
      end

      def print_deal_confirmation(deal_confirmation)
        print "Deal confirmation: #{deal_confirmation.deal_id}, #{deal_confirmation.deal_status}, "

        if deal_confirmation.deal_status == :accepted
          affected_deals = deal_confirmation.affected_deals.map(&:deal_id).join ','
          print "affected deals: #{affected_deals}, "
        else
          print "reason: #{deal_confirmation.reason}, "
        end

        puts "epic: #{deal_confirmation.epic}"
      end

      def print_market_overview(market)
        puts <<-END
#{market.epic}: \
#{market.instrument_name}, \
type: #{market.instrument_type}, \
bid: #{market.bid} \
offer: #{market.offer}
END
      end

      def print_position(position)
        profit_loss = Format.currency position.profit_loss, position.currency

        puts <<-END
#{position.deal_id}: \
#{position.formatted_size} of #{position.market.epic} at #{position.level}, \
profit/loss: #{profit_loss}
END
      end

      def print_sprint_market_position(sprint)
        size = Format.currency sprint.size, sprint.currency
        direction = { buy: 'above', sell: 'below' }.fetch(sprint.direction)
        seconds_till_expiry = Format.seconds sprint.seconds_till_expiry
        payout_amount = Format.currency sprint.payout_amount, sprint.currency

        puts <<-END
#{sprint.deal_id}: \
#{size} on #{sprint.epic} \
to be #{direction} #{sprint.strike_level} \
in #{seconds_till_expiry}, \
payout: #{payout_amount}
END
      end

      def print_transaction(transaction)
        profit_loss = Format.currency transaction.profit_and_loss_amount, transaction.currency

        puts <<-END
#{transaction.date.strftime '%F'} #{transaction.reference}: \
#{transaction.formatted_transaction_type}, \
#{"#{transaction.size} of " if transaction.size}\
#{transaction.instrument_name}, \
profit/loss: #{profit_loss}
END
      end

      def print_watchlist(watchlist)
        puts <<-END
#{watchlist.id}: #{watchlist.name}, \
editable: #{watchlist.editable}, \
deleteable: #{watchlist.deleteable}, \
default: #{watchlist.default_system_watchlist}
END
      end

      def print_working_order(order)
        size = format '%g', order.order_size

        puts <<-END
#{order.deal_id}: \
#{order.direction} #{size} of #{order.epic} at #{order.order_level}\
, limit distance: #{order.limit_distance || '-'}\
, stop distance: #{order.stop_distance || '-'}\
#{", good till #{order.good_till_date.utc.strftime '%F %R %z'}" if order.time_in_force == :good_till_date}
END
      end
    end
  end
end
