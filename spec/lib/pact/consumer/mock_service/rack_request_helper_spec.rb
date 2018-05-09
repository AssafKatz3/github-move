require 'spec_helper'
require 'pact/consumer/mock_service/rack_request_helper'

module Pact::Consumer

  describe RackRequestHelper do
    class TestSubject
      include RackRequestHelper
    end

    let(:rack_env) {
      {
             "CONTENT_LENGTH" => "16",
               "CONTENT_TYPE" => content_type,
          "GATEWAY_INTERFACE" => "CGI/1.1",
                  "PATH_INFO" => "/donuts",
               "QUERY_STRING" => "",
                "REMOTE_ADDR" => "127.0.0.1",
                "REMOTE_HOST" => "localhost",
             "REQUEST_METHOD" => "POST",
                "REQUEST_URI" => "http://localhost:4321/donuts",
                "SCRIPT_NAME" => "",
                "SERVER_NAME" => "localhost",
                "SERVER_PORT" => "4321",
            "SERVER_PROTOCOL" => "HTTP/1.1",
            "SERVER_SOFTWARE" => "WEBrick/1.3.1 (Ruby/1.9.3/2013-02-22)",
                "HTTP_ACCEPT" => "text/plain",
            "HTTP_USER_AGENT" => "Ruby",
                  "HTTP_HOST" => "localhost:4321",
           "HTTP_X_SOMETHING" => "1, 2",
               "rack.version" => [1, 2 ],
                 "rack.input" => StringIO.new(body),
                "rack.errors" => nil,
           "rack.multithread" => true,
          "rack.multiprocess" => false,
              "rack.run_once" => false,
            "rack.url_scheme" => "http",
               "HTTP_VERSION" => "HTTP/1.1",
               "REQUEST_PATH" => "/donuts"
      }
     }

     let(:content_type) { "" }
     let(:body) { '' }

    subject { TestSubject.new }

    let(:expected_request) {
      {
            :query => "",
           :method => "post",
             :body => expected_body,
             :path => "/donuts",
          :headers => {
              "Content-Type" => content_type,
              "Content-Length" => "16",
                    "Accept" => "text/plain",
                "User-Agent" => "Ruby",
                      "Host" => "localhost:4321",
                   "Version" => "HTTP/1.1",
                   "X-Something" => "1, 2"
          }
      }
    }

    let(:expected_body) { body }
    context "with a text body" do
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:body) { 'this is the body' }

      it "extracts the body" do
        expect(subject.request_as_hash_from(rack_env)).to eq expected_request
      end
    end

    context "with a json body" do
      let(:content_type) { "application/json" }
      let(:body) { '{"a" : "body" }' }
      let(:expected_body) { {"a" => "body"} }

      it "extracts the body" do
        expect(subject.request_as_hash_from(rack_env)).to eq expected_request
      end
    end

    context "with X_PACT_UNDERSCORED_HEADER_NAMES" do
      before do
        rack_env["HTTP_ACCESS_TOKEN"] = "123"
        rack_env["X_PACT_UNDERSCORED_HEADER_NAMES"] = "access_token"
      end

      let(:request) { subject.request_as_hash_from(rack_env) }

      it "sets any headers with underscores back to their original format" do
        expect(request[:headers]["access_token"]).to eq "123"
        expect(request[:headers]["X-Something"]).to eq "1, 2"
        expect(request[:headers].key?("Access-Token")).to be false
      end
    end
  end
end
