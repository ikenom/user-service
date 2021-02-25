# frozen_string_literal: true

class CreateUserConsumer
  include Hutch::Consumer
  consume "user.create"
  queue_name "consumer_user_service_create_user"

  def process(message)
    CreateUserJob.perform_later(
      email: message[:email],
      password: message[:password],
      display_name: message[:display_name],
      sender_id: message[:sender_id]
    )
  end
end
