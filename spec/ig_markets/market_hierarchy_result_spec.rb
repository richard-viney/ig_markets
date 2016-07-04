describe IGMarkets::MarketHierarchyResult, :dealing_platform do
  let(:market_hierarchy_result) do
    build(:market_hierarchy_result).tap do |model|
      dealing_platform_model model.nodes.first
    end
  end

  it 'returns the markets under a node' do
    expect(dealing_platform.markets).to receive(:hierarchy).with('174882').and_return(build(:market_hierarchy_result))
    expect(market_hierarchy_result.nodes.first.markets).to eq(market_hierarchy_result.markets)
  end

  it 'returns the nodes under a node' do
    expect(dealing_platform.markets).to receive(:hierarchy).with('174882').and_return(build(:market_hierarchy_result))
    expect(market_hierarchy_result.nodes.first.nodes).to eq(market_hierarchy_result.nodes)
  end
end
