describe IGMarkets::CLI::ClientSentimentsTable do
  it do
    client_sentiments = [
      build(:client_sentiment, market_id: 'A'),
      build(:client_sentiment, market_id: 'B', long_position_percentage: 75, short_position_percentage: 25),
      build(:client_sentiment, market_id: 'C', long_position_percentage: 10, short_position_percentage: 90)
    ]

    expect(IGMarkets::CLI::ClientSentimentsTable.new(client_sentiments, title: 'Title').to_s).to eql(<<-END.strip
+--------+--------+---------+
|           Title           |
+--------+--------+---------+
| Market | Long % | Short % |
+--------+--------+---------+
| A      |     60 |      40 |
| #{'B'.yellow}      |     #{'75'.yellow} |      #{'25'.yellow} |
| #{'C'.red}      |     #{'10'.red} |      #{'90'.red} |
+--------+--------+---------+
END
                                                                                                    )
  end
end
