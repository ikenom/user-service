# frozen_string_literal: true

class UpdateUserJob < ApplicationJob
  queue_as :default

  def perform(user_id:, name:, api_key:)
    user = User.find(user_id)
    firebase_client = FirebaseClient.new(api_key: api_key)
    firebase_client.update_user(id_token: user.id_token, name: name)

    Rails.logger.info "User #{user.id} updated with name #{name}"
  end
end