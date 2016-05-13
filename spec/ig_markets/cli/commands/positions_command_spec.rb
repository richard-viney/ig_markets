describe IGMarkets::CLI::Positions do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Positions.new [], arguments
  end

  it 'prints positions' do
    positions = [build(:position), build(:position, level: 100.1, contract_size: 100)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli.list }.to output(<<-END
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
|                                                                       Positions                                                                       |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
| Date                    | EPIC               | Type       | Direction | Size | Level | Current | High  | Low  | Limit | Stop | Profit/loss | Deal IDs |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
| 2015-07-24 09:12:37 UTC | CS.D.EURUSD.CFD.IP | Currencies | Buy       | 10.4 | 100.0 |   100.0 | 110.0 | 90.0 | 110.0 | 90.0 |    #{'USD 0.00'.green} | DEAL     |
| 2015-07-24 09:12:37 UTC | CS.D.EURUSD.CFD.IP | Currencies | Buy       | 10.4 | 100.1 |   100.0 | 110.0 | 90.0 | 110.0 | 90.0 | #{'USD -104.00'.red} | DEAL     |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+

Total profit/loss: #{'USD -104.00'.red}
END
                                 ).to_stdout
  end

  it 'prints positions in aggregate' do
    positions = [build(:position, level: 100.0, size: 0.1), build(:position, level: 130.0, size: 0.2)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli(aggregate: true).list }.to output(<<-END
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
|                                                               Positions                                                               |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
| Date | EPIC               | Type       | Direction | Size | Level | Current | High  | Low  | Limit | Stop | Profit/loss  | Deal IDs   |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
|      | CS.D.EURUSD.CFD.IP | Currencies | Buy       |  0.3 | 120.0 |   100.0 | 110.0 | 90.0 |       |      | #{'USD -6000.00'.red} | DEAL, DEAL |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+

Total profit/loss: #{'USD -6000.00'.red}
END
                                                  ).to_stdout
  end

  it 'creates a new position' do
    arguments = {
      currency_code: 'USD',
      direction: 'buy',
      epic: 'CS.D.EURUSD.CFD.IP',
      size: 2
    }

    expect(dealing_platform.positions).to receive(:create).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).create
  end

  it 'updates a position' do
    arguments = {
      limit_level: 20,
      stop_level: 30
    }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:update).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update 'DEAL'
  end

  it 'can remove a stop and limit from a position' do
    arguments = { limit_level: '', stop_level: 'stop_level' }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:update).with(limit_level: '', stop_level: nil).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update 'DEAL'
  end

  it 'closes a position' do
    arguments = { size: 1 }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)
    expect(position).to receive(:close).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

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
