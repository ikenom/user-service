# frozen_string_literal: true

class CreateUserJob < ApplicationJob
  queue_as :user_service_create_user

  def perform(sender_id:, email:, password:, display_name:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.sign_up(email: email, password: password)
    user = User.create!(
      firebase_id: payload["localId"],
      refresh_token: payload["refreshToken"]
    )

    Rails.logger.info "User #{user.id} was created"

    UpdateUserJob.perform_later(id_token: payload["idToken"], name: display_name)
    PublishJob.perform_later(
      sender_id: sender_id,
      queue_name: "user.created",
      user_id: user.id.to_s)

    user
  end
end
