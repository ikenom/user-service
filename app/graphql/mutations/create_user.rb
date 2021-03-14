module Mutations
  class CreateUser < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :display_name, String, required: true

    field :token, String, null: false
    field :user, Types::UserType, null: false

    def resolve(email:, password:, display_name:)
      hmac_secret = ENV["HMAC_SECRET"]
      user = CreateUserJob.perform_now(
        sender_id: nil,
        email: email,
        password: password,
        display_name: display_name)

      {
        token: JwtService.encode(payload: { refresh_token: user.refresh_token }, hmac_secret: hmac_secret),
        user: user
      }
    rescue FirebaseClient::EmailExistsError
      raise Errors::UserAlreadyExistsError, "User with email #{email} already exists"
    rescue FirebaseClient::PasswordInvalidError
      raise Errors::PasswordInvalidError, "Password provided is invalid"
    end
  end
end