describe IGMarkets::RequestPrinter do
  before do
    IGMarkets::RequestPrinter.enabled = true
  end

  after do
    IGMarkets::RequestPrinter.enabled = false
  end

  it 'prints options' do
    expect do
      options = {
        method: :get,
        url: 'url',
        headers: { name: 'value' },
        body: { data: 'ABC' }.to_json
      }

      IGMarkets::RequestPrinter.print_options options
    end.to output(<<-END
GET url
  Headers:
    Name: value
  Body: {
          "data": "ABC"
        }
END
                 ).to_stdout
  end

  it 'prints a JSON response body' do
    expect do
      IGMarkets::RequestPrinter.print_response_body({ data: 'ABC' }.to_json)
    end.to output(<<-END
  Response: {
              "data": "ABC"
            }
END
                 ).to_stdout
  end

  it 'prints an HTML response body' do
    expect do
      IGMarkets::RequestPrinter.print_response_body '<html></html>'
    end.to output(<<-END
  Response: <html></html>
END
                 ).to_stdout
  end
end
