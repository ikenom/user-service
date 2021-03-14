module Mutations
  class Login < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: false
    field :user, Types::UserType, null: false

    def resolve(email:, password:)
      hmac_secret = ENV["HMAC_SECRET"]
      user = LoginUserJob.perform_now(
        sender_id: nil,
        email: email,
        password: password)

      {
        token: JwtService.encode(payload: { refresh_token: user.refresh_token }, hmac_secret: hmac_secret),
        user: user
      }
    rescue FirebaseClient::EmailNotFound
      raise Errors::EmailNotFoundError, "User with email #{email} not found"
    rescue FirebaseClient::PasswordInvalidError
      raise Errors::PasswordInvalidError, "Password provided is invalid"
    end
  end
end