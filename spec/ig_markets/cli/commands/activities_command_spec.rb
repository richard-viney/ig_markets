describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  it 'prints activities from a recent number of days' do
    activities = [
      build(:activity, date: Time.new(2015, 12, 16, 15, 0, 0, 0)),
      build(:activity, date: Time.new(2015, 12, 15, 15, 0, 0, 0))
    ]

    expect(dealing_platform.account).to receive(:activities).with(days: 3).and_return(activities)

    expect { cli(days: 3, sort_by: 'date').activities }.to output(<<-END
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
|                                                             Activities                                                             |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
| Date                    | Channel | Type | Status   | EPIC               | Market          | Size | Level | Limit  | Stop | Result |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
| 2015-12-15 15:00:00 UTC | Charts  | S&L  | Accepted | CS.D.NZDUSD.CFD.IP | Spot FX NZD/USD |   +1 | 0.664 | 0.6649 |      | Result |
| 2015-12-16 15:00:00 UTC | Charts  | S&L  | Accepted | CS.D.NZDUSD.CFD.IP | Spot FX NZD/USD |   +1 | 0.664 | 0.6649 |      | Result |
+-------------------------+---------+------+----------+--------------------+-----------------+------+-------+--------+------+--------+
       END
                                                                 ).to_stdout
  end

  it 'prints activities from a number of days and a from date' do
    from = Date.new 2015, 01, 15
    to = Date.new 2015, 01, 18

    expect(dealing_platform.account).to receive(:activities).with(from: from, to: to).and_return([])

    expect { cli(days: 3, from: '2015-01-15', sort_by: 'date').activities }.to output(<<-END
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
