describe IGMarkets::RequestPrinter do
  before do
    described_class.enabled = true
  end

  after do
    described_class.enabled = false
  end

  it 'prints a request' do
    expect do
      options = {
        method: :get,
        url: 'url',
        headers: { 'Name' => 'value', '_method' => 'DELETE' },
        body: { data: 'ABC' }.to_json
      }

      described_class.print_request options
    end.to output(<<-MSG
GET url
  Headers:
    Name: value
    _method: DELETE
  Body:
    {
      "data": "ABC"
    }
    MSG
                 ).to_stdout
  end

  it 'prints a JSON response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: { data: 'ABC' }.to_json

    expect do
      described_class.print_response response
    end.to output(<<-MSG
  Response:
    Headers:
      Name: Value
    Body:
      {
        "data": "ABC"
      }
MSG
                 ).to_stdout
  end

  it 'prints an HTML response' do
    response = instance_double 'Excon::Response', headers: { 'Name' => 'Value' }, body: '<html></html>'

    expect do
      described_class.print_response response
    end.to output(<<-MSG
  Response:
    Headers:
      Name: Value
    Body:
      <html></html>
MSG
                 ).to_stdout
  end
end
