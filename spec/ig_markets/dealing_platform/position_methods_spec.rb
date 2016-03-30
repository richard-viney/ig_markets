describe IGMarkets::DealingPlatform::PositionMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the current positions' do
    positions = [build(:position)]

    get_result = {
      positions: positions.map(&:attributes).map do |a|
        { market: a[:market], position: a }
      end
    }

    expect(session).to receive(:get).with('positions', IGMarkets::API_VERSION_2).and_return(get_result)
    expect(platform.positions.all).to eq(positions)
  end

  it 'can retrieve a single position' do
    position = build :position

    expect(session).to receive(:get)
      .with("positions/#{position.deal_id}", IGMarkets::API_VERSION_2)
      .and_return(position: position.attributes, market: position.market)

    expect(platform.positions[position.deal_id]).to eq(position)
  end
end
