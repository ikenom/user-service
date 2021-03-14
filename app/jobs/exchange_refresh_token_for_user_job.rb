# frozen_string_literal: true

class ExchangeRefreshTokenForUserJob < ApplicationJob
  queue_as :user_service_refresh_token

  def perform(refresh_token:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.id_token(refresh_token: refresh_token)

    User.find_by(firebase_id: payload["user_id"])
  end
end
