describe IGMarkets::RequestFormatter do
  it 'formats a request' do
    options = {
      method: :get,
      url: 'url',
      headers: { 'Name' => 'value', '_method' => 'DELETE' },
      body: { data: 'ABC' }.to_json
    }

    expect(described_class.format_request(options)).to eq(<<-MSG
GET url
  Headers:
    Name: value
    _method: DELETE
  Body:
    {
      "data": "ABC"
    }
MSG
                                                         )
  end

  it 'formats a JSON response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: { data: 'ABC' }.to_json

    expect(described_class.format_response(response)).to eq(<<-MSG
  Response:
    Headers:
      Name: Value
    Body:
      {
        "data": "ABC"
      }
MSG
                                                           )
  end

  it 'formats an HTML response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: '<html></html>'

    expect(described_class.format_response(response)).to eq(<<-MSG
  Response:
    Headers:
      Name: Value
    Body:
      <html></html>
MSG
                                                           )
  end
end
