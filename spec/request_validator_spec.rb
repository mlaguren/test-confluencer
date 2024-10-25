require 'rspec'
require_relative '../lib/request_validator'

RSpec.describe RequestValidator do
  let(:expected_keys) { ["project", "pass", "fail", "skipped"] }

  describe '.validate_payload' do
    context 'when the payload is empty' do
      it 'returns an error for empty payload' do
        valid, result = RequestValidator.validate_test_results_payload('', expected_keys)
        expect(valid).to eq(false)
        expect(result[:error]).to eq("No Payload")
      end
    end

    context 'when the payload is invalid JSON' do
      it 'returns an error for invalid JSON' do
        invalid_json = '{invalid: "json"}'
        valid, result = RequestValidator.validate_test_results_payload(invalid_json, expected_keys)
        expect(valid).to eq(false)
        expect(result[:error]).to eq("Invalid JSON format")
      end
    end

    context 'when required keys are missing' do
      it 'returns an error with missing keys' do
        payload = { "project" => "Test Project", "pass" => "10" }.to_json
        valid, result = RequestValidator.validate_test_results_payload(payload, expected_keys)
        expect(valid).to eq(false)
        expect(result[:error]).to eq("Invalid request payload")
        expect(result[:missing_keys]).to contain_exactly("fail", "skipped")
        expect(result[:extra_keys]).to be_empty
      end
    end

    context 'when there are extra keys' do
      it 'returns an error with extra keys' do
        payload = { "project" => "Test Project", "pass" => "10", "fail" => "2", "skipped" => "1", "extra_key" => "value" }.to_json
        valid, result = RequestValidator.validate_test_results_payload(payload, expected_keys)
        expect(valid).to eq(false)
        expect(result[:error]).to eq("Invalid request payload")
        expect(result[:missing_keys]).to be_empty
        expect(result[:extra_keys]).to contain_exactly("extra_key")
      end
    end

    context 'when the payload is valid' do
      it 'returns true and parsed JSON when valid' do
        valid_payload = { "project" => "Test Project", "pass" => "10", "fail" => "2", "skipped" => "1" }.to_json
        valid, result = RequestValidator.validate_test_results_payload(valid_payload, expected_keys)
        expect(valid).to eq(true)
        expect(result).to eq(JSON.parse(valid_payload))
      end
    end
  end
end
