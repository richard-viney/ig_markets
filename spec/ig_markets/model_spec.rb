describe IGMarkets::Model do
  let(:test_model_class) do
    Class.new(IGMarkets::Model) do
      def self.name
        'TestModel'
      end

      attribute :id
      attribute :bool, IGMarkets::Boolean
      attribute :string, String, regex: /\A[A-Z]{3}\Z/, nil_if: '-'
      attribute :date, Date, format: ['%F', '%b-%y']
      attribute :time, Time, format: ['%FT%T', '%d-%b-%y']
      attribute :float, Float
      attribute :symbol, Symbol, allowed_values: %i[a b]

      deprecated_attribute :deprecated_0, :deprecated_1
    end
  end

  let(:nested_model_class) do
    internal_class = test_model_class

    Class.new(IGMarkets::Model) do
      def self.name
        'NestedModel'
      end

      attribute :test, internal_class
    end
  end

  let(:model) { test_model_class.new }

  it 'returns the attribute names' do
    expect(test_model_class.defined_attribute_names).to eq(%i[id bool string date time float symbol])
  end

  it 'reports unrecognized attributes' do
    expect(test_model_class.valid_attribute?(:id)).to be true

    expect do
      expect(test_model_class.valid_attribute?(:unknown)).to be false
    end.to output("ig_markets: unrecognized attribute TestModel#unknown\n").to_stderr

    expect do
      expect(test_model_class.valid_attribute?(:unknown)).to be false
    end.to output('').to_stderr
  end

  it "returns an attribute's type" do
    expect(test_model_class.attribute_type(:id)).to eq(String)
    expect(test_model_class.attribute_type(:time)).to eq(Time)
  end

  it "returns a deprecated attribute's type as NilClass" do
    expect(test_model_class.attribute_type(:deprecated_0)).to eq(NilClass)
  end

  it 'initializes with specified attribute values' do
    expect(test_model_class.new(id: 'test', bool: true).attributes)
      .to eq(id: 'test', bool: true, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'allows deprecated attributes to be get and set' do
    expect { test_model_class.new(deprecated_0: '0', deprecated_1: '1').deprecated_0 }.not_to raise_error
  end

  it 'fails when initialized with an unknown attribute' do
    expect { test_model_class.new id: 'test', unknown: '' }
      .to raise_error(ArgumentError, 'unknown attribute: TestModel#unknown, value: ""')
  end

  it 'duplicates itself' do
    instance = test_model_class.new id: '1'
    copy = instance.dup
    copy.id = '2'

    expect(instance.id).to eq('1')
  end

  it 'has attribute getter and setter methods' do
    %i[id id= bool bool= string string= date date= time time=
       float float= symbol symbol=].each do |method_name|
      expect(model.respond_to?(method_name)).to be(true)
    end
  end

  it 'has sanitize attribute class methods' do
    %i[sanitize_id_value sanitize_bool_value sanitize_string_value sanitize_date_value sanitize_time_value
       sanitize_float_value sanitize_symbol_value].each do |method_name|
      expect(test_model_class.respond_to?(method_name)).to be(true)
    end
  end

  it 'returns the attributes hash' do
    expect(model.attributes).to eq(id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'inspects attributes' do
    expect(model.inspect).to eq('#<TestModel id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, ' \
                                'symbol: nil>')
  end

  it 'converts a nested model to a nested hash' do
    model = nested_model_class.new test: test_model_class.new

    expect(model.to_h).to eq(test: { id: nil, bool: nil, string: nil, date: nil, time: nil, float: nil, symbol: nil })
  end

  it 'inspects attributes in nested models' do
    model = nested_model_class.new test: test_model_class.new

    expect(model.inspect).to eq('#<NestedModel test: #<TestModel id: nil, bool: nil, string: nil, date: nil, ' \
                                'time: nil, float: nil, symbol: nil>>')
  end

  it 'mass assigns attributes' do
    model.attributes = { id: '1', bool: false }

    expect(model.attributes).to eq(id: '1', bool: false, string: nil, date: nil, time: nil, float: nil, symbol: nil)
  end

  it 'raises an exception when a model attribute is set to the wrong type' do
    expect { nested_model_class.new test: nil }.not_to raise_error

    expect { nested_model_class.new test: 'string' }
      .to raise_error(ArgumentError, 'incorrect type set on NestedModel#test: "string"')
  end

  it 'converts an empty string to nil on a Float attribute' do
    model.float = 1.0
    model.float = ''

    expect(model.float).to be_nil
  end

  it 'accepts 0 and 1 on boolean attributes' do
    model.bool = '1'
    expect(model.bool).to be true

    model.bool = '0'
    expect(model.bool).to be false
  end

  it 'raises on an invalid boolean' do
    expect { model.bool = '' }.to raise_error(ArgumentError, 'TestModel#bool: invalid boolean value: ')
  end

  it 'raises when a string value does not match the regex' do
    expect { model.string = 'abc' }.to raise_error(ArgumentError, 'TestModel#string: invalid string value: abc')
  end

  it 'raises on an invalid date' do
    expect { model.date = '2015-29-01 A:B:C' }
      .to raise_error(ArgumentError, 'TestModel#date: failed parsing date: 2015-29-01 A:B:C')
  end

  it 'raises on an invalid time' do
    expect { model.time = '2015-29-01T09:30:40' }
      .to raise_error(ArgumentError, 'TestModel#time: failed parsing time: 2015-29-01T09:30:40')

    expect { model.time = '2015-29-01' }
      .to raise_error(ArgumentError, 'TestModel#time: failed parsing time: 2015-29-01')
  end

  it 'raises on an invalid float' do
    expect { model.float = 'a' }.to raise_error(ArgumentError, 'TestModel#float: invalid float value: a')
  end

  it 'raises on an invalid symbol' do
    expect { model.symbol = :wrong }.to raise_error(ArgumentError, 'TestModel#symbol: invalid value: :wrong')
  end

  it 'returns the allowed values for an attribute' do
    expect(test_model_class.allowed_values(:symbol)).to eq(%i[a b])
  end

  it 'sets attribute to nil when value matches a nil_if' do
    model.string = '-'
    expect(model.string).to be_nil
  end

  it 'parses a date in the expected formats' do
    model.date = '2015-01-10'
    expect(model.date).to eq(Date.new(2015, 1, 10))

    model.date = 'SEP-16'
    expect(model.date).to eq(Date.new(2016, 9, 1))
  end

  it 'parses a time in the expected formats' do
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

    it 'returns the attributes hash' do
      expect(model.attributes).to eq(id: 'id', bool: true, string: 'ABC', date: Date.new(2015, 1, 10),
                                     time: Time.new(2015, 1, 10, 6, 30, 0, '+00:00'), float: 1.0, symbol: :a)
    end

    it 'inspects attributes' do
      expect(model.inspect).to eq('#<TestModel id: "id", bool: true, string: "ABC", date: 2015-01-10, ' \
                                  'time: 2015-01-10 06:30:00 UTC, float: 1.0, symbol: :a>')
    end
  end
end
