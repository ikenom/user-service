# frozen_string_literal: true

require "vcr"

REQUEST_HEADERS = %w[
  Authorization
  Private-Token
].freeze

RESPONSE_HEADERS = %w[Set-Cookie].freeze

KEYS = %w[idToken refreshToken].freeze


VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    match_requests_on: [:method, :body, :uri,
                        VCR.request_matchers.uri_without_param(:key)],
    record: :once
  }

  config.filter_sensitive_data("<redacted-request>") do |interaction|
    REQUEST_HEADERS.each do |key|
      break interaction.request.headers[key].first if interaction.request.headers.key?(key)
    end
  end

  config.filter_sensitive_data("<redacted-response>") do |interaction|
    RESPONSE_HEADERS.each do |key|
      break interaction.response.headers[key].first if interaction.response.headers.key?(key)
    end
  end

  config.filter_sensitive_data("<redacted-key>") do |interaction|
    start_index = interaction.request.uri.index("key=")
    interaction.request.uri[(start_index + "key=".size)..interaction.request.uri.size]
  end

  KEYS.each do |key|
    config.filter_sensitive_data("<redacted-key>") do |interaction|
      payload = JSON.parse(interaction.request.body)
      payload[key] if payload.key? key
    end
  end

  KEYS.each do |key|
    config.filter_sensitive_data("<redacted-key>") do |interaction|
      payload = JSON.parse(interaction.response.body)
      payload[key] if payload.key? key
    end
  end
end
