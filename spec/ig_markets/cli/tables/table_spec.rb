describe IGMarkets::CLI::Table do
  class TableModel < IGMarkets::Model
    attribute :string
    attribute :boolean, IGMarkets::Boolean
    attribute :float, Float
  end

  class TestTable < IGMarkets::CLI::Table
    private

    def default_title
      'Test'
    end

    def headings
      %w(First Second Third)
    end

    def right_aligned_columns
      [2]
    end

    def row_color(model)
      model.boolean ? :red : nil
    end

    def row(model)
      [model.string, model.boolean, model.float]
    end
  end

  let(:models) do
    [
      TableModel.new(string: 'Test', boolean: true, float: -1.0),
      :separator,
      TableModel.new(string: 'Test', boolean: false, float: 0.1234)
    ]
  end

  it 'prints the correct table' do
    expect(TestTable.new(models).to_s + "\n").to eq(<<-END
+-------+--------+--------+
|          Test           |
+-------+--------+--------+
| First | Second | Third  |
+-------+--------+--------+
| #{'Test'.red}  | #{'Yes'.red}    |     #{'-1'.red} |
+-------+--------+--------+
| Test  | No     | 0.1234 |
+-------+--------+--------+
END
                                                   )
  end

  it 'can use a custom title' do
    expect(TestTable.new(models, title: 'Title').to_s + "\n").to eq(<<-END
+-------+--------+--------+
|          Title          |
+-------+--------+--------+
| First | Second | Third  |
+-------+--------+--------+
| #{'Test'.red}  | #{'Yes'.red}    |     #{'-1'.red} |
+-------+--------+--------+
| Test  | No     | 0.1234 |
+-------+--------+--------+
END
                                                                   )
  end
end
