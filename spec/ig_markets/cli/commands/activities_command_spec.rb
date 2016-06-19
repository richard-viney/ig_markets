describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    allow(Date).to receive(:today).and_return(Date.new(2016, 1, 5))
  end

  it 'prints activities from a recent number of days' do
    activities = [
      build(:activity, date: Time.new(2015, 12, 16, 15, 0, 0, 0)),
      build(:activity, date: Time.new(2015, 12, 15, 15, 0, 0, 0))
    ]

    expect(dealing_platform.account).to receive(:activities).with(from: Date.new(2016, 1, 2)).and_return(activities)

    expect do
      cli(days: 3, sort_by: 'date').activities
    end.to output("#{IGMarkets::CLI::ActivitiesTable.new [activities[1], activities[0]]}\n").to_stdout
  end

  it 'prints activities from a number of days and a from date' do
    from = Date.new 2015, 01, 15
    to = Date.new 2015, 01, 18

    expect(dealing_platform.account).to receive(:activities).with(from: from, to: to).and_return([])

    expect do
      cli(days: 3, from: '2015-01-15', sort_by: 'date').activities
    end.to output("#{IGMarkets::CLI::ActivitiesTable.new []}\n").to_stdout
  end

  it 'prints activities filtered by EPIC' do
    activities = [
      build(:activity, epic: 'CS.D.EURUSD.CFD.IP'),
      build(:activity, epic: 'CS.D.NZDUSD.CFD.IP')
    ]

    expect(dealing_platform.account).to receive(:activities).with(from: Date.new(2016, 1, 2)).and_return(activities)

    expect do
      cli(days: 3, sort_by: 'date', epic: 'NZD').activities
    end.to output("#{IGMarkets::CLI::ActivitiesTable.new activities[1]}\n").to_stdout
  end
end
