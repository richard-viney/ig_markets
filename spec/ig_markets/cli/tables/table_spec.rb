describe IGMarkets::CLI::Tables::Table do
  class TableModel < IGMarkets::Model
    attribute :string
    attribute :boolean, IGMarkets::Boolean
    attribute :float, Float
  end

  class TestTable < IGMarkets::CLI::Tables::Table
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

  let(:models) do
    [
      TableModel.new(string: 'Test', boolean: true, float: -1.0),
      :separator,
      TableModel.new(string: 'Test', boolean: false, float: 0.1234)
    ]
  end

  it 'prints the table' do
    expect(TestTable.new(models).to_s + "\n").to eq(<<-END
+-------+--------+--------+
|          Test           |
+-------+--------+--------+
| First | Second | Third  |
+-------+--------+--------+
| Test  | #{ColorizedString['Yes'].red}    |     -1 |
+-------+--------+--------+
| Test  | No     | 0.1234 |
+-------+--------+--------+
END
                                                   )
  end

  it 'uses a custom title' do
    expect(TestTable.new(models, title: 'Title').lines).to eq(['+-------+--------+--------+',
                                                               '|          Title          |',
                                                               '+-------+--------+--------+',
                                                               '| First | Second | Third  |',
                                                               '+-------+--------+--------+',
                                                               "| Test  | #{ColorizedString['Yes'].red}    |     -1 |",
                                                               '+-------+--------+--------+',
                                                               '| Test  | No     | 0.1234 |',
                                                               '+-------+--------+--------+'])
  end
end
