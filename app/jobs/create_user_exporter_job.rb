# frozen_string_literal: true

class CreateUserExporterJob < ApplicationJob
  queue_as :user_service_create_user_exporter

  def perform(sender_id:, user_id:)
    Hutch.connect

    user = User.find(user_id)
    Hutch.publish("user.created",
                  sender_id: sender_id,
                  auth_id: user.firebase_id)
  end
end
