# frozen_string_literal: true

class CreateVendorJob < ApplicationJob
  queue_as :user_service_create_vendor

  def perform(email:, password:, business_name:, first_name:, last_name:, phone:)
    api_key = ENV["FIREBASE_API_KEY"]
    firebase_client = FirebaseClient.new(api_key: api_key)
    payload = firebase_client.sign_up(email: email, password: password)

    vendor = Vendor.create!(
      firebase_id: payload["localId"],
      id_token: payload["idToken"],
      refresh_token: payload["refreshToken"],
      email: email,
      business_name: business_name,
      first_name: first_name,
      last_name: last_name,
      phone: phone
    )

    Rails.logger.info "Vendor #{vendor.id} was created"

    full_name = full_name(first: first_name, last: last_name)
    UpdateUserJob.perform_later(user_id: vendor.id.to_s, name: full_name)
    CreateVendorExporterJob.perform_later(user_id: vendor.id.to_s)
  end

  private

  def full_name(first:, last:)
    "#{first} #{last}"
  end
end
