require 'spec_helper'
require 'multi_json'

describe HubspotEvents::Client do
  let(:client)   { HubspotEvents::Client.new('x') }
  let(:response) { double("Response", code: 200) }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }
  }

  def api_uri(path)
    "https://api.hubapi.com/integrations/v1/#{path}"
  end

  describe "#track" do
    it "sends a track event" do
      body = '{"name":"purchase"}'
      stub_request(:post, api_uri('track'))
        .with(body: body, headers: headers)
        .to_return(status: 200, body: "", headers: {})

      client.track(5, "purchase", {})
    end

    it "sends any optional event attributes" do
      body = '{"name":"purchase","type":"socks","price":"13.99","timestamp":null'
      stub_request(:post, api_uri('track'))
        .with(body: body, headers: headers)
        .to_return(status: 200, body: "", headers: {})

      client.track(5, "purchase", type: "socks", price: "13.99")
    end

    it "allows sending of a created_at date" do
      stub_request(:post, api_uri('track'))
        .with(body: {
          orgId: 'x',
          userId: 5,
          event: "purchase",
          attributes: {
            type: "socks",
            price: "13.99",
          },
          timestamp: 1561231234
        }, headers: headers)
        .to_return(status: 200, body: "", headers: {})

      client.track(5, "purchase", type: "socks", price: "13.99", created_at: 1561231234)
    end
  end
end
