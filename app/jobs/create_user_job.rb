# frozen_string_literal: true

class CreateUserJob < ApplicationJob
  queue_as :user_service_create_user

  def perform(email:, password:, name:, type:, api_key:)
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.sign_up(email: email, password: password)

    user = User.create!(
      firebase_id: payload["localId"],
      id_token: payload["idToken"],
      refresh_token: payload["refreshToken"],
      type: type
    )

    Rails.logger.info "User #{user.id} was created"

    UpdateUserJob.perform_later(user_id: user.id.to_s, name: name, api_key: api_key)
    CreateUserExporterJob.perform_later(user_id: user.id.to_s, name: name, type: type)
  end
end
