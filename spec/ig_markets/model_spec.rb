describe IGMarkets::Model do
  class TestModel < IGMarkets::Model
    attribute :id
    attribute :bool, IGMarkets::Boolean
    attribute :string, String, regex: /\A[A-Z]{3}\Z/, nil_if: '-'
    attribute :date, Date, format: '%F'
    attribute :time, Time, format: ['%FT%T', '%d-%b-%y']
    attribute :float, Float
    attribute :symbol, Symbol, allowed_values: [:a, :b]

    deprecated_attribute :deprecated_0, :deprecated_1
  end

  let(:model) { TestModel.new }

  it 'returns the attribute names' do
    expect(TestModel.defined_attribute_names).to eq([:id, :bool, :string, :date, :time, :float, :symbol])
  end

  it 'reports unrecognized attributes' do
    expect(TestModel.valid_attribute?(:id)).to be true

    expect do
      expect(TestModel.valid_attribute?(:unknown)).to be false
    end.to output("ig_markets: unrecognized attribute TestModel#unknown\n").to_stderr

    expect do
      expect(TestModel.valid_attribute?(:unknown)).to be false
    end.to output('').to_stderr
  end

  it 'returns an attribute\'s type' do
    expect(TestModel.attribute_type(:id)).to eq(String)
    expect(TestModel.attribute_type(:time)).to eq(Time)
  end

  it 'returns a deprecated attribute\'s type as NilClass' do
    expect(TestModel.attribute_type(:deprecated_0)).to eq(NilClass)
  end

  it 'initializes with specified attribute values' do
    expect(TestModel.new(id: 'test', bool: true).attributes).to eq(id: 'test', bool: true, string: nil, date: nil,
                                                                   time: nil, float: nil, symbol: nil)
  end

  it 'allows deprecated attributes to be set' do
    expect { TestModel.new(deprecated_0: '0', deprecated_1: '1') }.not_to raise_error
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
     :float, :float=, :symbol, :symbol=].each do |method_name|
      expect(model.respond_to?(method_name)).to eq(true)
    end
  end

  it 'has the correct sanitize class methods' do
    [:sanitize_id_value, :sanitize_bool_value, :sanitize_string_value, :sanitize_date_value, :sanitize_time_value,
     :sanitize_float_value, :sanitize_symbol_value].each do |method_name|
      expect(TestModel.respond_to?(method_name)).to eq(true)
    end
  end

  it 'has the correct attributes hash' do
    expect(model.attributes).to eq(id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'inspects attributes' do
    expect(model.inspect).to eq('#<TestModel id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, ' \
                                'symbol: nil>')
  end

  it 'inspects attributes in nested models' do
    class TestModel2 < IGMarkets::Model
      attribute :test, TestModel
    end

    model = TestModel2.new test: TestModel.new

    expect(model.inspect).to eq('#<TestModel2 test: #<TestModel id: nil, bool: nil, string: nil, date: nil, ' \
                                'time: nil, float: nil, symbol: nil>>')
  end

  it 'mass assigns attributes' do
    model.attributes = { id: '1', bool: false }

    expect(model.attributes).to eq(id: '1', bool: false, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'raises an exception when a model attribute is set to the wrong type' do
    class TestModel2 < IGMarkets::Model
      attribute :test, TestModel
    end

    expect { TestModel2.new test: nil }.to_not raise_error
    expect { TestModel2.new test: 'string' }.to raise_error(ArgumentError)
  end

  it 'converts an empty string to nil on a Float attribute' do
    model.float = 1.0
    model.float = ''

    expect(model.float).to be_nil
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
    expect { model.time = '2015-29-01T09:30:40' }.to raise_error(ArgumentError)
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
    expect(model.string).to be_nil
  end

  it 'correctly parses a date in the expected format' do
    model.date = '2015-01-10'
    expect(model.date).to eq(Date.new(2015, 1, 10))
  end

  it 'correctly parses a time in the expected formats' do
    model.time = '2015-01-10T09:30:25'
    expect(model.time).to eq(Time.new(2015, 1, 10, 9, 30, 25, '+00:00'))

    model.time = '20-FEB-11'
    expect(model.time).to eq(Time.new(2011, 2, 20, 0, 0, 0, '+00:00'))
  end

  context 'with all attributes set' do
    before do
      model.id = 'id'
      model.bool = true
      model.string = 'ABC'
      model.date = '2015-01-10'
      model.time = '2015-01-10T06:30:00'
      model.float = '1.0'
      model.symbol = 'a'
    end

    it 'has the correct attributes hash' do
      expect(model.attributes).to eq(id: 'id', bool: true, string: 'ABC', date: Date.new(2015, 1, 10),
                                     time: Time.new(2015, 1, 10, 6, 30, 0, '+00:00'), float: 1.0, symbol: :a)
    end

    it 'inspects attributes' do
      expect(model.inspect).to eq('#<TestModel id: "id", bool: true, string: "ABC", date: 2015-01-10, ' \
                                  'time: 2015-01-10 06:30:00 UTC, float: 1.0, symbol: :a>')
    end
  end
end
