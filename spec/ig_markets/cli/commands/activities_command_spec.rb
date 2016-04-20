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
    activities = [build(:account_activity)]

    expect(dealing_platform.account).to receive(:recent_activities).with(3).and_return(activities)

    expect { cli(days: 3).activities }.to output(<<-END
+------------+-----------------+--------------------+------+-------+--------+
|                                Activities                                 |
+------------+-----------------+--------------------+------+-------+--------+
| Date       | Deal ID         | EPIC               | Size | Level | Result |
+------------+-----------------+--------------------+------+-------+--------+
| 2015-12-20 | DIAAAAA4HDKPQEQ | CS.D.NZDUSD.CFD.IP | +1   | 0.664 | Result |
+------------+-----------------+--------------------+------+-------+--------+
END
                                                ).to_stdout
  end

  it 'prints activities from a number of days and a start date' do
    start_date = Date.new 2015, 01, 15
    end_date = Date.new 2015, 01, 18

    expect(dealing_platform.account).to receive(:activities_in_date_range).with(start_date, end_date).and_return([])

    expect { cli(days: 3, start_date: '2015-01-15').activities }.to output(<<-END
+------+---------+------+------+-------+--------+
|                  Activities                   |
+------+---------+------+------+-------+--------+
| Date | Deal ID | EPIC | Size | Level | Result |
+------+---------+------+------+-------+--------+
+------+---------+------+------+-------+--------+
END
                                                                          ).to_stdout
  end
end
