# frozen_string_literal: true

FactoryBot.define do
  factory :vendor, class: Vendor, parent: :user do
    business_name { Faker::Company.name }
    phone { Faker::PhoneNumber.cell_phone }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
  end
end
