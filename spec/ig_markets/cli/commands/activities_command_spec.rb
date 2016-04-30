describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform

    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints activities from a recent number of days' do
    activities = [build(:activity)]

    expect(dealing_platform.account).to receive(:activities).with(days: 3).and_return(activities)

    expect { cli(days: 3).activities }.to output(<<-END
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
|                                                             Activities                                                             |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
| Date                    | Channel | Type | Status   | EPIC               | Market          | Size | Level | Limit  | Stop | Result |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
| 2015-12-15 15:00:00 UTC | Charts  | S&L  | Accepted | CS.D.NZDUSD.CFD.IP | Spot FX NZD/USD |   +1 | 0.664 | 0.6649 |      | Result |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
       END
                                                ).to_stdout
  end

  it 'prints activities from a number of days and a from date' do
    from = Date.new 2015, 01, 15
    to = Date.new 2015, 01, 18

    expect(dealing_platform.account).to receive(:activities).with(from: from, to: to).and_return([])

    expect { cli(days: 3, from: '2015-01-15').activities }.to output(<<-END
+------+---------+------+--------+------+--------+------+-------+-------+------+--------+
|                                      Activities                                       |
+------+---------+------+--------+------+--------+------+-------+-------+------+--------+
| Date | Channel | Type | Status | EPIC | Market | Size | Level | Limit | Stop | Result |
+------+---------+------+--------+------+--------+------+-------+-------+------+--------+
+------+---------+------+--------+------+--------+------+-------+-------+------+--------+
END
                                                                    ).to_stdout
  end
end
