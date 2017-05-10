describe IGMarkets::CLI::Main, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    allow(Time).to receive(:now).and_return(Time.new(2016, 1, 5))
  end

  it 'prints activities from a recent number of days' do
    activities = [
      build(:activity, date: Time.new(2015, 12, 16, 15, 0, 0, 0)),
      build(:activity, date: Time.new(2015, 12, 15, 15, 0, 0, 0))
    ]

    expect(dealing_platform.account).to receive(:activities).with(from: Time.new(2016, 1, 2)).and_return(activities)

    expect do
      cli(days: 3, sort_by: 'date').activities
    end.to output("#{IGMarkets::CLI::Tables::ActivitiesTable.new [activities[1], activities[0]]}\n").to_stdout
  end

  it 'prints activities from a number of days and a from time' do
    from = Time.new 2015, 1, 15, 6, 0, 0, '+04:00'
    to = Time.new 2015, 1, 18, 6, 0, 0, '+04:00'

    expect(dealing_platform.account).to receive(:activities).with(from: from, to: to).and_return([])

    expect do
      cli(days: 3, from: '2015-01-15T06:00:00+04:00', sort_by: 'date').activities
    end.to output("#{IGMarkets::CLI::Tables::ActivitiesTable.new []}\n").to_stdout
  end

  it 'prints activities filtered by EPIC' do
    activities = [
      build(:activity, epic: 'CS.D.EURUSD.CFD.IP'),
      build(:activity, epic: 'CS.D.NZDUSD.CFD.IP')
    ]

    expect(dealing_platform.account).to receive(:activities).with(from: Time.new(2016, 1, 2)).and_return(activities)

    expect do
      cli(days: 3, sort_by: 'date', epic: 'NZD').activities
    end.to output("#{IGMarkets::CLI::Tables::ActivitiesTable.new activities[1]}\n").to_stdout
  end
end
