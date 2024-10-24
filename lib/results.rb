# frozen_string_literal: true
require_relative 'confluence_table'

module Results
  def self.get_results(project = nil)
    pass_rate_page = ConfluenceTable.new(ENV['PAGE'], ENV['ATLASSIAN_TOKEN'], "melvin.laguren@ecoatm.com")
    page = JSON.parse(pass_rate_page.fetch_page)
    document = Nokogiri::HTML(page.dig('body', 'storage', 'value'))
    table = document.at('table')

    return extract_project_results(table, project) if project

    extract_all_suites(table).to_json
  end

  private

  def self.extract_all_suites(table)
    table.css('tbody tr').each_with_object([]) do |row, suites|
      columns = row.xpath('td').map(&:text)
      next if columns.empty?

      suites << {
        name: columns[0],
        pass: columns[1],
        fail: columns[2],
        skipped: columns[3],
        pass_rate: columns[4]
      }
    end
  end

  def self.extract_project_results(table, project)
    row = table.at_xpath("//tr[td[text()='#{project}'] or td/p[text()='#{project}']]")
    return {}.to_json unless row
    {
      pass: row.at_css('td:nth-child(2)').text,
      fail: row.at_css('td:nth-child(3)').text,
      skipped: row.at_css('td:nth-child(4)').text,
      pass_rate: row.at_css('td:nth-child(5)').text
    }.to_json
  end
end
