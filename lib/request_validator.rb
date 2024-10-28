# frozen_string_literal: true

module RequestValidator
  REQUIRED_KEYS = ["project", "pass", "fail", "skipped"].freeze
  def self.validate_test_results_payload(request_body, expected_keys)
    if request_body.nil? || request_body.strip.empty?
      return [false, { "error": "Request body cannot be empty" }]
    end

    begin
      parsed_json = JSON.parse(request_body)
      rescue JSON::ParserError => e
        return [false, { "error": "Invalid JSON format", "details": e.message }]
      rescue StandardError => e
        return [false, { "error": "Error processing JSON", "details": e.message }]
    end

    missing_keys = expected_keys - parsed_json.keys
    extra_keys = parsed_json.keys - expected_keys

    unless missing_keys.empty? && extra_keys.empty?
      return [false, { "error": "Invalid request payload", "missing_keys": missing_keys, "extra_keys": extra_keys }]
    end

    [true, parsed_json]
  end
end
