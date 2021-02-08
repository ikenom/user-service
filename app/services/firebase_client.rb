# frozen_string_literal: true

class FirebaseClient
  class EmailExistsError < RuntimeError; end
  class PasswordInvalidError < RuntimeError; end

  attr_reader :connection, :api_key

  def initialize(api_key:)
    @api_key = api_key
    @connection = Faraday.new(
      url: "https://identitytoolkit.googleapis.com",
      headers: { "Content-Type" => "application/json" }
    ) do |faraday|
      faraday.response(:json, content_type: /\bjson$/)
    end
  end

  def sign_up(email:, password:)
    payload = {
      email: email,
      password: password
    }

    url = "v1/accounts:signUp?key=#{api_key}"
    response = connection.post(url, payload.to_json)

    case response.status
    when 400
      raise EmailExistsError if response.body["error"]["message"].include?("EMAIL_EXISTS")
      raise PasswordInvalidError if response.body["error"]["message"].include?("WEAK_PASSWORD")
    end

    response.body
  end
end
