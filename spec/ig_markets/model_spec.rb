describe IGMarkets::Model do
  class TestModel < IGMarkets::Model
    attribute :id
    attribute :bool, IGMarkets::Boolean
    attribute :string, String, regex: /\A[A-Z]{3}\Z/, nil_if: '-'
    attribute :date, Date, format: '%F'
    attribute :time, Time, format: '%F %T', time_zone: '+0630'
    attribute :float, Float
    attribute :symbol, Symbol, allowed_values: [:a, :b]
  end

  let(:model) { TestModel.new }

  it 'initializes with specified attribute values' do
    expect(TestModel.new(id: 'test', bool: true).attributes).to eq(
      id: 'test', bool: true, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'fails when initialized with an unknown attribute' do
    expect { TestModel.new id: 'test', unknown: '' }.to raise_error(ArgumentError)
  end

  it 'duplicates itself correctly' do
    instance = TestModel.new id: '1'
    copy = instance.dup
    copy.id = '2'

    expect(instance.id).to eq('1')
  end

  it 'has the correct getter and setter methods' do
    [:id, :id=, :bool, :bool=, :string, :string=, :date, :date=, :time, :time=,
     :float, :float=, :symbol, :symbol=].each do |id|
      expect(model.respond_to?(id)).to eq(true)
    end
  end

  it 'has the correct attributes hash' do
    expect(model.attributes).to eq(id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'inspects attributes' do
    expect(model.inspect).to eq(
      '#<TestModel id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil>')
  end

  it 'inspects attributes in nested models' do
    class TestModel2 < IGMarkets::Model
      attribute :test, TestModel
    end

    model = TestModel2.new test: TestModel.new

    expect(model.inspect).to eq(
      '#<TestModel2 test: #<TestModel id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil>>')
  end

  it '#from accepts nil' do
    expect(TestModel.from(nil)).to eq(nil)
  end

  it '#from accepts an attributes hash' do
    expect(TestModel.from(id: 'test').attributes).to eq(
      id: 'test', bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it '#from accepts an instance and creates a copy' do
    instance = TestModel.new(id: 'test')

    expect(TestModel.from(instance)).to eq(instance)
    expect(TestModel.from(instance)).not_to eql(instance)
  end

  it '#from accepts an Array of attributes hashes' do
    expect(TestModel.from([{ id: 'a' }, { id: 'b' }])).to eq([TestModel.new(id: 'a'), TestModel.new(id: 'b')])
  end

  it '#from raises on invalid inputs' do
    ['', Time.new, IGMarkets::Model.new].each do |invalid_input|
      expect { TestModel.from(invalid_input) }.to raise_error(ArgumentError)
    end
  end

  it 'converts an empty string to nil on a Float attribute' do
    model.float = 1.0
    model.float = ''

    expect(model.float).to eq(nil)
  end

  it 'raises ArgumentError for an invalid boolean' do
    expect { model.bool = '' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError when string value does not match the regex' do
    expect { model.string = 'abc' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid date' do
    expect { model.date = '2015-29-01 A:B:C' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid time' do
    expect { model.time = '2015-29-01 09:30:40' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid time' do
    expect { model.time = '2015-29-01' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid float' do
    expect { model.float = 'a' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid symbol' do
    expect { model.symbol = :invalid }.to raise_error(ArgumentError)
  end

  it 'returns the correct set of allowed values for an attribute' do
    expect(TestModel.allowed_values(:symbol)).to eq([:a, :b])
  end

  it 'sets attribute to nil when value matches a nil_if' do
    model.string = '-'
    expect(model.string).to eq(nil)
  end

  it 'correctly parses a date in the expected format' do
    model.date = '2015-01-10'
    expect(model.date).to eq(Date.new(2015, 1, 10))
  end

  it 'correctly parses a time in the expected format' do
    model.time = '2015-01-10 09:30:25'
    expect(model.time).to eq(Time.new(2015, 1, 10, 9, 30, 25, '+06:30'))
  end

  context 'with all attributes set' do
    before do
      model.id = 'id'
      model.bool = true
      model.string = 'ABC'
      model.date = '2015-01-09'
      model.time = '2015-01-10 00:00:00'
      model.float = '1.0'
      model.symbol = 'a'
    end

    it 'has the correct attributes hash' do
      expect(model.attributes).to eq(
        id: 'id', bool: true, string: 'ABC', date: Date.new(2015, 1, 9), time: Time.new(2015, 1, 10, 0, 0, 0, '+06:30'),
        float: 1.0, symbol: :a)
    end

    it 'inspects attributes' do
      expect(model.inspect).to eq(
        '#<TestModel id: "id", bool: true, string: "ABC", date: 2015-01-09, time: 2015-01-09 17:30:00 UTC, ' \
        'float: 1.0, symbol: :a>')
    end
  end
end
