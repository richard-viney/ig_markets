describe IGMarkets::CLI::Tables::ActivitiesTable do
  it 'prints activities' do
    activities = [build(:activity)]
    activities[0].details.actions.first.action_type = :position_opened

    expect(described_class.new(activities).to_s).to eql(<<~MSG.strip
      +-------------------------------------------------------------------------------------------------------------------------------------------------+
      |                                                                   Activities                                                                    |
      +-------------------------+---------+----------+----------+--------------------+-----------------+------+-------+--------+------+-----------------+
      | Date                    | Channel | Type     | Status   | EPIC               | Market          | Size | Level | Limit  | Stop | Result          |
      +-------------------------+---------+----------+----------+--------------------+-----------------+------+-------+--------+------+-----------------+
      | 2015-12-15 15:00:00 UTC | Web     | Position | Accepted | CS.D.NZDUSD.CFD.IP | Spot FX NZD/USD |   +1 | 0.664 | 0.6649 |      | Position opened |
      +-------------------------+---------+----------+----------+--------------------+-----------------+------+-------+--------+------+-----------------+
    MSG
                                                       )
  end
end
