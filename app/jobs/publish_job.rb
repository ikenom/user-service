# frozen_string_literal: true

class PublishJob < ApplicationJob
  queue_as :user_service_publish

  def perform(sender_id:, queue_name:, **payload)
    Hutch.connect
    Hutch.publish(queue_name, sender_id: sender_id, **payload)
  end
end
