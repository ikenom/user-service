class JwtService
  class TokenExpiredError < RuntimeError; end

  class << self
    def encode(payload:, hmac_secret:)
      JWT.encode payload, hmac_secret, 'HS512'
    end

    def decode_for_user(token:, hmac_secret:)
      payload = JWT.decode(token, hmac_secret, true, { algorithm: 'HS512' })
      refresh_token = payload.select { |item| item.include?("refresh_token") }.first["refresh_token"]
      ExchangeRefreshTokenForUserJob.perform_now(refresh_token: refresh_token)
    rescue FirebaseClient::TokenExpiredError
      raise TokenExpiredError
    end
  end
end
