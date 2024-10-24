# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'

class ConfluenceTable
  BASE_URL = "#{ENV['CONFLUENCE_URL']}/wiki/api/v2/pages/"
  puts BASE_URL

  def initialize(page_id, api_token, username)
    @page_id = page_id
    @api_token = api_token
    @username = username
    @auth_header = "Basic #{Base64.strict_encode64("#{@username}:#{@api_token}")}"
  end

  def fetch_page
    url = URI("#{BASE_URL}#{@page_id}?body-format=storage")
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = @auth_header
    response = send_request(url, request)
    json = response.body
  end

  def update_table(project_key, column_2, column_3, column_4)
    page_json = fetch_page
    current_version = page_json['version']['number']

    document = Nokogiri::HTML(page_json['body']['storage']['value'])
    table = document.at('table')

    row = table.xpath('//tr[td/p[text()="API"]]')
    row.at_css('td:nth-child(2) p').content = project_key.to_s
    row.at_css('td:nth-child(3) p').content = column_2.to_s
    row.at_css('td:nth-child(4) p').content = column_3.to_s
    row.at_css('td:nth-child(5) p').content = column_4.to_s

    update_page(page_json['title'], document, current_version + 1)
  end

  private

  def send_request(url, request)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.request(request)
  end

  def update_page(title, updated_document, new_version)
    url = URI("#{BASE_URL}#{@page_id}")
    request = Net::HTTP::Put.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = @auth_header
    request["User-Agent"] = "Mozilla/5.0"

    body = {
      id: @page_id,
      status: "current",
      title: title,
      body: {
        representation: "storage",
        value: updated_document.at('html').to_s
      },
      version: {
        number: new_version,
        message: "API Test"
      }
    }

    request.body = body.to_json
    response = send_request(url, request)
    response.body
  end
end
