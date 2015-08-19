describe IGMarkets::Model do
  class TestModel < IGMarkets::Model
    attribute :id
    attribute :bool, type: :boolean
    attribute :date, type: :date_time, format: '%Y-%m-%d'
    attribute :cost, type: :float
  end

  let(:model) { TestModel.new }

  it 'initializes with specified attribute values' do
    expect(TestModel.new(id: 'test', bool: true).attributes).to eq(id: 'test', bool: true, date: nil, cost: nil)
  end

  it 'fails when initialized with an unknown attribute' do
    expect { TestModel.new id: 'test', unknown: '' }.to raise_error(ArgumentError)
  end

  it 'has the correct getter and setter methods' do
    [:id, :id=, :bool, :bool=, :date, :date=, :cost, :cost=].each do |id|
      expect(model.respond_to?(id)).to eq(true)
    end
  end

  it 'has the correct attributes hash' do
    expect(model.attributes).to eq(id: nil, bool: nil, date: nil, cost: nil)
  end

  it 'inspects correctly' do
    expect(model.inspect).to eq('#<TestModel id: , bool: , date: , cost: >')
  end

  it '#from accepts nil' do
    expect(TestModel.from(nil)).to eq(nil)
  end

  it '#from accepts an attributes hash' do
    expect(TestModel.from(id: 'test').attributes).to eq(id: 'test', bool: nil, date: nil, cost: nil)
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
    ['', DateTime.new, IGMarkets::Model.new].each do |invalid_input|
      expect { TestModel.from(invalid_input) }.to raise_error(ArgumentError)
    end
  end

  it 'raises ArgumentError for an invalid boolean' do
    expect { model.bool = '' }.to raise_error(ArgumentError)
  end

  it 'correctly parses a date in the expected format' do
    model.date = '2015-01-10'
    expect(model.date).to eq(DateTime.new(2015, 1, 10))
  end

  it 'raises ArgumentError for an invalid date' do
    expect { model.date = '2015-29-01' }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for an invalid float' do
    expect { model.cost = 'a' }.to raise_error(ArgumentError)
  end

  context 'with all attributes set' do
    before do
      model.id = 'test'
      model.bool = true
      model.date = '2015-01-10'
      model.cost = '1.0'
    end

    it 'has the correct attributes hash' do
      expect(model.attributes).to eq(id: 'test', bool: true, date: DateTime.new(2015, 1, 10), cost: 1.0)
    end

    it 'inspects correctly' do
      expect(model.inspect).to eq('#<TestModel id: test, bool: true, date: 2015-01-10T00:00:00+00:00, cost: 1.0>')
    end
  end
end
