require 'json'

class TestResultsProcessor
  # Initialize with a JSON string or a hash
  def initialize(test_results_json)
    @test_results = parse_json(test_results_json)
  end

  # Method to calculate and add the pass rate
  def add_pass_rate
    total_tests = @test_results['pass'].to_i + @test_results['fail'].to_i + @test_results['skipped'].to_i
    if total_tests > 0
      pass_rate = (@test_results['pass'].to_f / total_tests * 100).round(2)
    else
      pass_rate = 0.0
    end
    @test_results['pass_rate'] = pass_rate
    @test_results
  end

  def as_json(options = nil)
    @test_results
  end

  def to_json(*args)
    as_json.to_json(*args)
  end

  private

  # Helper method to parse the input JSON
  def parse_json(json)
    if json.is_a?(String)
      JSON.parse(json)
    elsif json.is_a?(Hash)
      json
    else
      raise ArgumentError, 'Invalid input format. Expected a JSON string or a Hash.'
    end
  end
end