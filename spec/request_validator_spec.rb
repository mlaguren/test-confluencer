require 'rspec'
require_relative '../lib/request_validator'

RSpec.describe RequestValidator do
  let(:expected_keys) { RequestValidator::REQUIRED_KEYS }

  describe '.validate_test_results_payload' do
    context 'when request body is nil' do
      it 'returns an error about empty request body' do
        result = RequestValidator.validate_test_results_payload(nil, expected_keys)
        expect(result).to eq([false, { "error": "Request body cannot be empty" }])
      end
    end

    context 'when request body is empty string' do
      it 'returns an error about empty request body' do
        result = RequestValidator.validate_test_results_payload('', expected_keys)
        expect(result).to eq([false, { "error": "Request body cannot be empty" }])
      end
    end

    context 'when request body contains invalid JSON' do
      it 'returns an error about invalid JSON format' do
        result = RequestValidator.validate_test_results_payload('invalid-json', expected_keys)
        expect(result[0]).to be(false)
        expect(result[1][:error]).to eq("Invalid JSON format")
      end
    end

    context 'when request body is valid JSON but has missing keys' do
      it 'returns an error about missing keys' do
        request_body = { "project" => "MyProject", "pass" => "10" }.to_json
        result = RequestValidator.validate_test_results_payload(request_body, expected_keys)
        expect(result).to eq([false, { "error": "Invalid request payload", "missing_keys": ["fail", "skipped"], "extra_keys": [] }])
      end
    end

    context 'when request body is valid JSON but has extra keys' do
      it 'returns an error about extra keys' do
        request_body = { "project" => "MyProject", "pass" => "10", "fail" => "2", "skipped" => "1", "extra" => "extra_value" }.to_json
        result = RequestValidator.validate_test_results_payload(request_body, expected_keys)
        expect(result).to eq([false, { "error": "Invalid request payload", "missing_keys": [], "extra_keys": ["extra"] }])
      end
    end

    context 'when request body is valid JSON with correct keys' do
      it 'returns true and parsed JSON' do
        request_body = { "project" => "MyProject", "pass" => "10", "fail" => "2", "skipped" => "1" }.to_json
        result = RequestValidator.validate_test_results_payload(request_body, expected_keys)
        expect(result).to eq([true, { "project" => "MyProject", "pass" => "10", "fail" => "2", "skipped" => "1" }])
      end
    end

    context 'when a standard error occurs during parsing' do
      it 'handles the standard error' do
        allow(JSON).to receive(:parse).and_raise(StandardError, "Something went wrong")
        result = RequestValidator.validate_test_results_payload('{ "project": "Test" }', expected_keys)
        expect(result).to eq([false, { "error": "Error processing JSON", "details": "Something went wrong" }])
      end
    end
  end
end
