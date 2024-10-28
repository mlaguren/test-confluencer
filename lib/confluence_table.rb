# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'

class ConfluenceTable
  BASE_URL = "#{ENV['CONFLUENCE_URL']}/wiki/api/v2/pages/"

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
    unless response.is_a?(Net::HTTPSuccess)
      raise "Failed to fetch page: #{response.code} - #{response.message}"
    end
    response.body
  end

  def update_table(project, pass, fail, skipped, pass_rate)
    page_json = JSON.parse fetch_page
    current_version = page_json['version']['number']
    document = Nokogiri::HTML(page_json['body']['storage']['value'])
    table = document.at('table')
    row = table.xpath("//tr[td/p[text()='#{project}']]")
    row.at_css('td:nth-child(2) p').content = pass.to_s
    row.at_css('td:nth-child(3) p').content = fail.to_s
    row.at_css('td:nth-child(4) p').content = skipped.to_s
    row.at_css('td:nth-child(5) p').content = "#{pass_rate.to_s}%"

    update_page(page_json['title'], document, current_version + 1, project)
  end

  private

  def send_request(url, request)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.request(request)
  end

  def update_page(title, updated_document, new_version, project)
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
        message: "Updated Test Results from #{project} regression"
      }
    }
    request.body = body.to_json
    response = send_request(url, request)
    unless response.is_a?(Net::HTTPSuccess)
      raise "Failed to update page: #{response.code} - #{response.message}"
    end
    JSON.parse(response.body)
  end
end
