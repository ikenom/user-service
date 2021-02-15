# frozen_string_literal: true

class CreateVendorExporterJob < ApplicationJob
  queue_as :user_service_create_vendor_exporter

  def perform(user_id:)
    Hutch.connect

    vendor = Vendor.find(user_id)
    Hutch.publish("user.vendor.created",
                    user_id: vendor.id.to_s,
                    first_name: vendor.first_name,
                    last_name: vendor.last_name,
                    business_name: vendor.business_name,
                    email: vendor.email,
                    phone: vendor.phone)
  end
end
