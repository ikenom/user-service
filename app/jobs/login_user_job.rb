# frozen_string_literal: true

class LoginUserJob < ApplicationJob
  queue_as :user_service_login_user

  def perform(sender_id:, email:, password:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.login(email: email, password: password)

    user = User.find_by(firebase_id: payload["localId"])
    user.update!(refresh_token: payload["refreshToken"])

    Rails.logger.info "User #{user.id} has logged in"

    user
  end
end
