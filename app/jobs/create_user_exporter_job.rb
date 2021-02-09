# frozen_string_literal: true

class CreateUserExporterJob < ApplicationJob
  queue_as :default

  def perform(user_id:, name:, type:)
    Hutch.connect
    Hutch.publish("user.created",
                  user: {
                    id: user_id,
                    name: name,
                    type: type
                  })
  end
end
