require 'rspec'
require 'nokogiri'
require 'json'
require_relative '../lib/results'

RSpec.describe Results do
  let(:mock_page_content) {
    {
      'body' => {
        'storage' => {
          'value' => "<html><body><table><tbody>" \
                     "<tr><td>Suite 1</td><td>5</td><td>2</td><td>1</td><td>83%</td></tr>" \
                     "<tr><td>Suite 2</td><td>10</td><td>1</td><td>0</td><td>91%</td></tr>" \
                     "</tbody></table></body></html>"
        }
      }
    }.to_json
  }

  before do
    # Mock the ConfluenceTable class
    allow_any_instance_of(ConfluenceTable).to receive(:fetch_page).and_return(mock_page_content)
  end

  describe '.get_results' do
    context 'when project is nil' do
      it 'returns all test suites' do
        result = JSON.parse(Results.get_results)

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]['name']).to eq('Suite 1')
        expect(result[1]['pass_rate']).to eq('91%')
      end
    end

=begin
    context 'when project is provided and exists' do
      it 'returns the results for the specified project' do
        result = JSON.parse(Results.get_results('Suite 1'))
        pp result
        expect(result).to be_a(Hash)
        expect(result['pass']).to eq('5')
        expect(result['fail']).to eq('2')
        expect(result['pass_rate']).to eq('83%')
      end
    end
=end

    context 'when project is provided but does not exist' do
      it 'returns an empty result' do
        result = JSON.parse(Results.get_results('Nonexistent Suite'))

        expect(result).to be_a(Hash)
        expect(result).to be_empty
      end
    end
  end
end
