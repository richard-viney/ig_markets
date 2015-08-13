describe IGMarkets::Model do
  class TestModel < IGMarkets::Model
    attribute :name
    attribute :enabled, type: :boolean
    attribute :starts_at, type: :date_time, format: '%Y-%m-%d'
  end

  let(:model) { TestModel.new }

  it 'initializes with specified attribute values' do
    expect(TestModel.new(name: 'test', enabled: true).attributes).to eq(name: 'test', enabled: true, starts_at: nil)
  end

  it 'fails when initialized with an unknown attribute' do
    expect { TestModel.new name: 'test', unknown: '' }.to raise_error(ArgumentError)
  end

  it 'has the correct getter and setter methods' do
    [:name, :name=, :enabled, :enabled=, :starts_at, :starts_at=].each do |name|
      expect(model.respond_to?(name)).to eq(true)
    end
  end

  it 'has the correct attributes hash' do
    expect(model.attributes).to eq(name: nil, enabled: nil, starts_at: nil)
  end

  it 'inspects correctly' do
    expect(model.inspect).to eq('#<TestModel name: , enabled: , starts_at: >')
  end

  it '#from accepts nil' do
    expect(TestModel.from(nil)).to eq(nil)
  end

  it '#from accepts an attributes hash' do
    expect(TestModel.from(name: 'test').attributes).to eq(name: 'test', enabled: nil, starts_at: nil)
  end

  it '#from accepts an instance and creates a copy' do
    instance = TestModel.new(name: 'test')

    expect(TestModel.from(instance)).to eq(instance)
    expect(TestModel.from(instance)).not_to eql(instance)
  end

  it '#from raises on invalid inputs' do
    ['', IGMarkets::Model.new].each do |invalid_input|
      expect { TestModel.from(invalid_input) }.to raise_error(ArgumentError)
    end
  end

  it 'raises ArgumentError for an invalid boolean' do
    expect { model.enabled = '' }.to raise_error(ArgumentError)
  end

  it 'correctly parses a date in the expected format' do
    model.starts_at = '2015-01-10'
    expect(model.starts_at).to eq(DateTime.new(2015, 1, 10))
  end

  it 'raises ArgumentError for an invalid date' do
    expect { model.starts_at = '2015-29-01' }.to raise_error(ArgumentError)
  end

  context 'with all attributes set' do
    before do
      model.name = 'test'
      model.enabled = true
      model.starts_at = '2015-01-10'
    end

    it 'has the correct attributes hash' do
      expect(model.attributes).to eq(name: 'test', enabled: true, starts_at: DateTime.new(2015, 1, 10))
    end

    it 'inspects correctly' do
      expect(model.inspect).to eq('#<TestModel name: test, enabled: true, starts_at: 2015-01-10T00:00:00+00:00>')
    end
  end
end
