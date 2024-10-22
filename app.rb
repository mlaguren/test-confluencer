require 'sinatra'
require 'json'
require_relative 'lib/test_results_processor'

post '/api/test_results' do

  request_body = request.body.read.strip

  # Return error if the body is empty or contains only whitespace
  if request_body.empty?
    halt 400, { "error": "No Payload" }.to_json
  end

  # Parse the JSON and handle parsing errors
  test_results = JSON.parse(request_body) rescue halt(400, { "error": "Invalid JSON format" }.to_json)

  # Validate required keys
  expected_keys = ["project", "pass", "fail", "skipped"]
  missing_keys = expected_keys - test_results.keys
  extra_keys = test_results.keys - expected_keys

  unless missing_keys.empty? && extra_keys.empty?
    halt 400, { "error": "Invalid request payload", "missing_keys": missing_keys, "extra_keys": extra_keys }.to_json
  end

  # Process results and return with 201 status
  pass_fail_results = TestResultsProcessor.new(test_results)
  halt 201, pass_fail_results.add_pass_rate.to_json

end
