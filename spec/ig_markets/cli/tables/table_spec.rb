describe IGMarkets::CLI::Tables::Table do
  let(:model_class) do
    Class.new(IGMarkets::Model) do
      attribute :string
      attribute :boolean, IGMarkets::Boolean
      attribute :float, Float
    end
  end

  let(:table_class) do
    Class.new(IGMarkets::CLI::Tables::Table) do
      private

      def default_title
        'Test'
      end

      def headings
        %w[First Second Third]
      end

      def right_aligned_columns
        [2]
      end

      def row(model)
        [model.string, model.boolean, model.float]
      end

      def cell_color(value, _model, _row_index, column_index)
        column_index == 1 && value && :red
      end
    end
  end

  let(:models) do
    [
      model_class.new(string: 'Test', boolean: true, float: -1.0),
      :separator,
      model_class.new(string: 'Test', boolean: false, float: 0.1234)
    ]
  end

  it 'prints the table' do
    expect("#{table_class.new(models)}\n").to eq(<<~MSG
      +-------------------------+
      |          Test           |
      +-------+--------+--------+
      | First | Second | Third  |
      +-------+--------+--------+
      | Test  | #{ColorizedString['Yes'].red}    |     -1 |
      +-------+--------+--------+
      | Test  | No     | 0.1234 |
      +-------+--------+--------+
    MSG
                                                )
  end

  it 'uses a custom title' do
    expect("#{table_class.new(models, title: 'Title')}\n").to eq(<<~MSG
      +-------------------------+
      |          Title          |
      +-------+--------+--------+
      | First | Second | Third  |
      +-------+--------+--------+
      | Test  | #{ColorizedString['Yes'].red}    |     -1 |
      +-------+--------+--------+
      | Test  | No     | 0.1234 |
      +-------+--------+--------+
    MSG
                                                                )
  end
end
