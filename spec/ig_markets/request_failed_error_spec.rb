describe IGMarkets::Session do
  it 'constructs from an error message' do
    error = IGMarkets::RequestFailedError.new 'message'

    expect(error.error).to eq('message')
    expect(error.http_code).to eq(nil)
    expect(error.message).to eq('#<IGMarkets::RequestFailedError error: message>')
  end

  it 'constructs from an error message and HTTP code' do
    error = IGMarkets::RequestFailedError.new 'message', '404'

    expect(error.error).to eq('message')
    expect(error.http_code).to eq(404)
    expect(error.message).to eq('#<IGMarkets::RequestFailedError error: message, http_code: 404>')
  end
end
