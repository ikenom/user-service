# frozen_string_literal: true

class CreateUserConsumer
  include Hutch::Consumer
  consume "user.create"
  queue_name 'consumer_user_service_create_user'

  def process(message)
    CreateUserJob.perform_later(
      email: message[:email],
      password: message[:password],
      name: message[:name],
      type: message[:type],
      api_key: ENV["FIREBASE_API_KEY"]
    )
  end
end
