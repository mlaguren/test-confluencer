require 'rspec'
require 'json'
require_relative '../lib/test_results_processor'


RSpec.describe TestResultsProcessor, unit: true do
  let(:valid_json) { '{"project":"test_project", "pass":10, "fail":5, "skipped":5}' }
  let(:valid_hash) { { "project" => "test_project", "pass" => 10, "fail" => 5, "skipped" => 5 } }
  let(:empty_test_results) { { "project" => "test_project", "pass" => 0, "fail" => 0, "skipped" => 0 } }

  describe '#initialize' do
    it 'parses a valid JSON string' do
      processor = TestResultsProcessor.new(valid_json)
      expect(processor.instance_variable_get(:@test_results)).to eq(valid_hash)
    end

    it 'accepts a hash as input' do
      processor = TestResultsProcessor.new(valid_hash)
      expect(processor.instance_variable_get(:@test_results)).to eq(valid_hash)
    end

    it 'raises an ArgumentError for invalid input types' do
      expect { TestResultsProcessor.new(123) }.to raise_error(ArgumentError, 'Invalid input format. Expected a JSON string or a Hash.')
    end
  end

  describe '#add_pass_rate' do
    it 'calculates and adds the pass rate correctly when tests are present' do
      processor = TestResultsProcessor.new(valid_hash)
      result = processor.add_pass_rate
      expect(result['pass_rate']).to eq(44.0) # (10/20) * 100 = 50.0
    end

    it 'sets pass rate to 0.0 when no tests are present' do
      processor = TestResultsProcessor.new(empty_test_results)
      result = processor.add_pass_rate
      expect(result['pass_rate']).to eq(0.0)
    end
  end

  describe '#to_json' do
    it 'returns the updated hash as a JSON string' do
      processor = TestResultsProcessor.new(valid_hash)
      processor.add_pass_rate
      json_output = processor.to_json
      expected_output = valid_hash.merge("pass_rate" => 50.0).to_json
      expect(json_output).to eq(expected_output)
    end
  end
end

