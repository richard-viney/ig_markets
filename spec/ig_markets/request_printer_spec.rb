describe IGMarkets::RequestPrinter do
  before do
    IGMarkets::RequestPrinter.enabled = true
  end

  after do
    IGMarkets::RequestPrinter.enabled = false
  end

  it 'prints a request' do
    expect do
      options = {
        method: :get,
        url: 'url',
        headers: { 'Name' => 'value', '_method' => 'DELETE' },
        body: { data: 'ABC' }.to_json
      }

      IGMarkets::RequestPrinter.print_request options
    end.to output(<<-END
GET url
  Headers:
    Name: value
    _method: DELETE
  Body:
    {
      "data": "ABC"
    }
END
                 ).to_stdout
  end

  it 'prints a JSON response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: { data: 'ABC' }.to_json

    expect do
      IGMarkets::RequestPrinter.print_response response
    end.to output(<<-END
  Response:
    Headers:
      Name: Value
    Body:
      {
        "data": "ABC"
      }
END
                 ).to_stdout
  end

  it 'prints an HTML response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: '<html></html>'

    expect do
      IGMarkets::RequestPrinter.print_response response
    end.to output(<<-END
  Response:
    Headers:
      Name: Value
    Body:
      <html></html>
END
                 ).to_stdout
  end
end
