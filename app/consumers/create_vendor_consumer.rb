# frozen_string_literal: true

class CreateVendorConsumer
  include Hutch::Consumer
  consume "user.vendor.create"
  queue_name "consumer_user_service_create_vendor"

  def process(message)
    CreateVendorJob.perform_later(
      email: message[:email],
      password: message[:password],
      business_name: message[:business_name],
      first_name: message[:first_name],
      last_name: message[:last_name],
      phone: message[:phone]
    )
  end
end
