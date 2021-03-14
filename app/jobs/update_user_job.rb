# frozen_string_literal: true

class UpdateUserJob < ApplicationJob
  queue_as :user_service_update_user

  def perform(id_token:, name:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    firebase_client.update_user(id_token: id_token, name: name)
  end
end
