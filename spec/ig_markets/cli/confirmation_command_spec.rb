describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints a deal confirmation that was accepted' do
    deal_confirmation = build :deal_confirmation

    expect(dealing_platform).to receive(:deal_confirmation).with('deal_id').and_return(deal_confirmation)

    expect { cli.confirmation deal_confirmation.deal_id }.to output(<<-END
Deal confirmation: deal_id, accepted, affected deals: , epic: CS.D.EURUSD.CFD.IP
END
                                                                   ).to_stdout
  end

  it 'prints a deal confirmation that was rejected' do
    deal_confirmation = build :deal_confirmation, deal_status: :rejected, reason: :unknown

    expect(dealing_platform).to receive(:deal_confirmation).with('deal_id').and_return(deal_confirmation)

    expect { cli.confirmation deal_confirmation.deal_id }.to output(<<-END
Deal confirmation: deal_id, rejected, reason: unknown, epic: CS.D.EURUSD.CFD.IP
END
                                                                   ).to_stdout
  end
end
