require 'net/http'
require 'multi_json'

module HubspotEvents
  DEFAULT_URI = 'https://api.hubapi.com/integrations/v1/'.freeze

  class Client
    class InvalidRequest < RuntimeError; end
    class InvalidResponse < RuntimeError
      attr_reader :response

      def initialize(message, response)
        @message = message
        @response = response
      end
    end

    def initialize(app_id, options = {})
      @app_id = app_id
      @api_token = options[:api_token]
      @base_uri = options[:base_uri] || DEFAULT_URI
    end

    def track(email, event_type_id, name, attributes = {})
      body = {
        id: "#{@app_id}-#{SecureRandom.urlsafe_base64(16)}",
        email: email,
        name: name,
        timestamp: attributes.delete('occurred_at'),
        eventTypeId: event_type_id
      }
      body.merge!(attributes)

      perform_request('/timeline/event', body)
    end

  private

    def perform_request(path, attributes)
      uri = URI.parse(@base_uri)
      uri.path = uri.path + @app_id.to_s + path

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Put.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_token}"
      request.body = attributes.to_json

      http.request(request)
    end
  end
end
