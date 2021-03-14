# frozen_string_literal: true

class FirebaseClient
  class EmailExistsError < RuntimeError; end
  class PasswordInvalidError < RuntimeError; end
  class IDTokenInvalidError < RuntimeError; end
  class EmailNotFound < RuntimeError; end
  class TokenExpiredError < RuntimeError; end

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

  def login(email:, password:)
    payload = {
      email: email,
      password: password,
      returnSecureToken: true
    }

    url = "v1/accounts:signInWithPassword?key=#{api_key}"
    response = connection.post(url, payload.to_json)

    case response.status
    when 400
      raise EmailNotFound if response.body["error"]["message"].include?("EMAIL_NOT_FOUND")
      raise PasswordInvalidError if response.body["error"]["message"].include?("INVALID_PASSWORD")
    end

    response.body
  end

  def id_token(refresh_token:)
    payload = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
    }

    url = "https://securetoken.googleapis.com/v1/token?key=#{api_key}"
    response = connection.post(url, payload.to_json)

    case response.status
    when 400
      raise TokenExpiredError if response.body["error"]["message"].include?("TOKEN_EXPIRED")
    end

    response.body
  end

  def update_user(id_token:, name:)
    payload = {
      idToken: id_token,
      displayName: name
    }

    url = "v1/accounts:update?key=#{api_key}"
    response = connection.post(url, payload.to_json)

    case response.status
    when 400
      raise IDTokenInvalidError if response.body["error"]["message"].include?("INVALID_ID_TOKEN")
    end

    response.body
  end
end
