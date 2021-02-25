# frozen_string_literal: true

class CreateUserJob < ApplicationJob
  queue_as :user_service_create_user

  def perform(sender_id:, email:, password:, display_name:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.sign_up(email: email, password: password)

    user = User.create!(
      firebase_id: payload["localId"],
      id_token: payload["idToken"],
      refresh_token: payload["refreshToken"],
    )

    Rails.logger.info "User #{user.id} was created"

    UpdateUserJob.perform_later(user_id: user.id.to_s, name: display_name)
    CreateUserExporterJob.perform_later(sender_id: sender_id, user_id: user.id.to_s)
  end
end
