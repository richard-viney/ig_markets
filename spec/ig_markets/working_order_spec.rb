describe IGMarkets::WorkingOrder do
  include_context 'dealing_platform'

  let(:working_order) { with_dealing_platform build(:working_order, deal_id: '1') }

  it 'can delete a working order' do
    result = { deal_reference: 'reference' }

    expect(session).to receive(:delete).with('workingorders/otc/1', nil, IGMarkets::API_V2).and_return(result)

    expect(working_order.delete).to eq('reference')
  end

  it 'can update a working order' do
    payload = {
      goodTillDate: '2015/10/30 12:59:00',
      level: 1.03,
      limitDistance: 20,
      stopDistance: 30,
      timeInForce: 'GOOD_TILL_DATE',
      type: 'LIMIT'
    }

    put_result = { deal_reference: 'reference' }

    expect(session).to receive(:put).with('workingorders/otc/1', payload).and_return(put_result)
    expect(working_order.update(level: 1.03, limit_distance: 20, stop_distance: 30)).to eq('reference')
  end
end
