describe IGMarkets::CLI::Positions, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Positions.new [], arguments
  end

  it 'prints positions' do
    positions = [build(:position), build(:position, level: 100.1, contract_size: 100)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli.list }.to output(<<~MSG
      #{IGMarkets::CLI::Tables::PositionsTable.new positions}

      Total profit/loss: #{ColorizedString['USD -104.00'].red}
    MSG
                                 ).to_stdout
  end

  it 'prints positions in aggregate' do
    positions = [build(:position, level: 100.0, size: 0.1), build(:position, level: 130.0, size: 0.2)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli(aggregate: true).list }.to output(<<~MSG
      #{IGMarkets::CLI::Tables::PositionsTable.new positions, aggregate: true}

      Total profit/loss: #{ColorizedString['USD -6000.00'].red}
    MSG
                                                  ).to_stdout
  end

  it 'creates a new position' do
    arguments = {
      currency_code: 'USD',
      direction: 'buy',
      epic: 'CS.D.EURUSD.CFD.IP',
      size: 2
    }

    expect(dealing_platform.positions).to receive(:create).with(arguments).and_return('reference')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('reference')

    cli(arguments).create
  end

  it 'updates a position' do
    arguments = {
      limit_level: 20,
      stop_level: 30
    }

    position = build(:position)

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:update).with(arguments).and_return('reference')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('reference')

    cli(arguments).update 'DEAL'
  end

  it 'removes a stop and limit from a position' do
    arguments = { limit_level: '', stop_level: 'stop_level' }

    position = build(:position)

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:update).with({ limit_level: '', stop_level: nil }).and_return('reference')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('reference')

    cli(arguments).update 'DEAL'
  end

  it 'closes a position' do
    arguments = { size: 1 }

    position = build(:position)

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:close).with(arguments).and_return('reference')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('reference')

    cli(arguments).close 'DEAL'
  end

  it 'closes all positions' do
    positions = [build(:position), build(:position)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)
    expect(positions[0]).to receive(:close).and_return('ref0')
    expect(positions[1]).to receive(:close).and_return('ref1')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref0')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref1')

    cli.close_all
  end
end
