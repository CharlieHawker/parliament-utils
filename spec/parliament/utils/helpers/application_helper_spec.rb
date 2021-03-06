require 'spec_helper'

RSpec.describe Parliament::Utils::Helpers::ApplicationHelper do
  describe '#data_check' do
    # Crate a dummy class that includes our module
    # Also, set up all methods etc needed for our test (there are overridden in each test)
    let(:dummy_class) do
      Class.new do
        include Parliament::Utils::Helpers::ApplicationHelper

        ROUTE_MAP=nil

        def request; end
        def params; end
        def response; end
        def redirect_to(_); end
      end
    end

    # Used for ROUTE_MAP
    let(:route_map) do
      {
        foo: proc do
          double(
            :request,
            query_url: 'https://api.parliament.uk/foo?bar=true&test=abc'
          )
        end
      }
    end

    # Stub a request object
    let(:request_formats) { [ 'application/json' ] }
    let(:request_url) { 'https://localhost:3000/people/12345678' }
    let(:request) { double(:request, formats: request_formats, url: request_url) }

    # Stub a params object
    let(:params) { { action: 'foo' } }

    # Stub a response object
    let(:response) { double(:response, headers: {}) }

    context 'with a URL that contains an extenstion' do
      let(:request_url) { 'https://localhost:3000/people/12345678.json?foo=true' }

      it 'redirects to the api url, including the extension' do
        instance = dummy_class.new
        stub_const("ROUTE_MAP", route_map)
        allow(instance).to receive(:request).and_return(request)
        allow(instance).to receive(:params).and_return(params)
        allow(instance).to receive(:response).and_return(response)
        allow(instance).to receive(:redirect_to).with('https://api.parliament.uk/foo.json?bar=true&test=abc').and_return(:as_expected)

        expect(instance.data_check).to eq(:as_expected)
      end
    end

    context 'with a URL that does not contain an extenstion' do
      it 'redirects to the api url' do
        instance = dummy_class.new
        stub_const("ROUTE_MAP", route_map)
        allow(instance).to receive(:request).and_return(request)
        allow(instance).to receive(:params).and_return(params)
        allow(instance).to receive(:response).and_return(response)
        allow(instance).to receive(:redirect_to).with('https://api.parliament.uk/foo?bar=true&test=abc').and_return(:as_expected)

        expect(instance.data_check).to eq(:as_expected)
      end
    end
  end
end
