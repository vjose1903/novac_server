# lib/client.rb
require 'faraday'
require 'json'

module BaseRequest
  class Client
    API_BASE_URL = ENV.fetch('API_BASE_URL_DGII_MICROSERVICE')
    BASE_URL_PREFIX = 'api'
    BASE_URL_VERSION = 'v1'

    def initialize(path='')
      @path = path
      @conn = Faraday.new(url: "#{API_BASE_URL}/#{BASE_URL_PREFIX}/#{BASE_URL_VERSION}") do |f|
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end
    end

    def get_all(options = {})
      url = make_url(options)
      request(:get, url, nil, options)
    end

    def get_one(id, options = {})
      url = make_url(options, id)
      request(:get, url, nil, options)
    end

    def delete_one(id, options = {})
      url = make_url(options, id)
      request(:delete, url, nil, options)
    end

    def create_one(data, options = {})
      url = make_url(options)
      request(:post, url, data, options)
    end

    def update_one(id, data, options = {})
      url = make_url(options, id)
      request(:patch, url, data, options)
    end

    def create_update_one(data, options = {})
      if data['id'].nil? || data['id'].to_i == 0
        create_one(data, options)
      else
        update_one(data['id'], data, options)
      end
    end

    def dynamic(http_method, data = nil, options = {})
      url = make_url(options)
      request(http_method.downcase.to_sym, url, data, options)
    end

    private

    def make_url(options = {}, id = nil)
      url = "#{@path}"
      url += "/#{id}" if id
      url += "/#{options[:after_path]}" if options[:after_path]

      url += parse_query_params(options[:parameters]) if options[:parameters]
      url
    end

    def parse_query_params(params)
      return '' if params.empty?

      query_string = params.map do |key, value|
        encoded_value = value.is_a?(String) ? URI.encode_www_form_component(value) : value
        "#{key}=#{encoded_value}"
      end.join('&')

      "?#{query_string}"
    end

    def request(method, url, data = nil, options = {})
      headers = {
        'Content-Type' => 'application/json; charset=UTF-8',
        'Accept' => 'application/json'
      }.merge(options[:custom_headers] || {})

      response = if [:get, :delete].include?(method)
                   @conn.public_send(method, url, nil, headers)
                 else
                   @conn.public_send(method, url, data.to_json, headers)
                 end

      parse_response(response)
    end

    def parse_response(response)
      body = JSON.parse(response.body) rescue {}

      {
        status: response.status,
        data: body['data'],
        message: body['message'],
      }
    end
  end
end
