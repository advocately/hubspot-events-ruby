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
        timestamp: attributes[:occurred_at],
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

      response = http.request(request)
      handle_json_response(response)
    end

    def handle_json_response(response)
      case response.code.to_i
      when 200, 201, 202, 204
        Utils.symbolize_keys(JSON.load(response.body))
      when 401
        raise AuthenticationError, response
      when 406
        raise UnsupportedFormatRequestedError, response
      when 422
        raise ResourceValidationError, response
      when 503
        raise ServiceUnavailableError, response
      else
        raise GeneralAPIError, response
      end
    end
  end
end
