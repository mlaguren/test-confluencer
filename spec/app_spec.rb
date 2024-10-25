# spec/app_spec.rb
require 'rspec'
require 'spec_helper'

RSpec.describe 'TestResults API', type: :request, integration: true do
  describe 'POST /api/test_results' do
    context 'when the payload is valid' do
      let(:valid_payload) { { project: 'API', pass: 10, fail: 5, skipped: 5 }.to_json }

      it 'returns a 201 status' do
        post '/api/test_results', valid_payload, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(201)
        # expect(JSON.parse(last_response.body)['message']).to eq('Results processed')
      end
    end

    context 'when the payload is empty' do
      it 'returns a 400 status with an error message' do
        post '/api/test_results', '', { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)['error']).to eq('No Payload')
      end
    end

    context 'when the JSON is invalid' do
      it 'returns a 400 status with an invalid JSON error message' do
        post '/api/test_results', '{invalid json}', { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)['error']).to eq('Invalid JSON format')
      end
    end

    context 'when required keys are missing' do
      let(:invalid_payload) { { project: 'test_project' }.to_json }

      it 'returns a 400 status with an invalid payload error message' do
        post '/api/test_results', invalid_payload, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)['error']).to eq('Invalid request payload')
      end
    end
  end

  describe 'GET /api/test_results' do
    context 'all projects' do
      it 'returns a 200 status with an error message' do
        get '/api/test_results', '', { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end
    end
    context 'a projects' do
      it 'returns a 200 status with an error message' do
        get '/api/test_results?project=API', '', { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end
    end
  end
end
