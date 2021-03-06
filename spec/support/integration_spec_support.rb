module Pact
  module IntegrationTestSupport

    TMP = 'tmp'
    LOG_PATH = 'tmp/integration.log'
    PACT_DIR = 'tmp/pacts'

    def wait_until_server_started port
      tries = 0
      begin
        Faraday.delete "http://localhost:#{port}/interactions",
          nil,
          {'X-Pact-Mock-Service' => 'true'}
      rescue Faraday::ConnectionFailed => e
        sleep 0.1
        tries += 1
        retry if tries < 100
      end
    end

    def clear_dirs
      FileUtils.rm_rf TMP
    end

    def expected_interaction
      {
        description: "a request for a greeting",
        request: {
          method: :get,
          headers: {'Foo' => 'Bar'},
          path: '/greeting'
        },
        response: {
          status: 200,
          headers: { 'Content-Type' => 'text/plain' },
          body: "Hello world"
        }
      }.to_json
    end

    def mock_service_headers
      {
        'Content-Type' => 'application/json',
        'X-Pact-Mock-Service' => 'true'
      }
    end

    def pact_details
      {
        consumer: { name: 'Consumer' },
        provider: { name: 'Provider' }
      }.to_json
    end

    def setup_interaction port
      Faraday.post "http://localhost:#{port}/interactions",
        expected_interaction,
        mock_service_headers
    end

    def invoke_expected_request port
      Faraday.get "http://localhost:#{port}/greeting",
        nil,
        {'Foo' => 'Bar'}
    end

    def write_pact port
      Faraday.post "http://localhost:#{port}/pact",
        pact_details,
        mock_service_headers
    end

    def connect_via_ssl port
      connection = Faraday.new "https://localhost:#{port}", ssl: { verify: false }
      connection.delete "/interactions", nil, {'X-Pact-Mock-Service' => 'true'}
    end

    def make_options_request port
      Faraday.run_request :options,
        "http://localhost:#{port}/interactions",
        nil,
        {'Access-Control-Request-Headers' => 'foo'}
    end
  end
end
