# frozen_string_literal: true

# field :business_name, type: String
#   field :email, type: String
#   field :phone, type: String
#   field :first_name, type: String
#   field :last_name, type: String

FactoryBot.define do
  factory :vendor, class: Vendor, parent: :user do
    business_name { Faker::Company.name }
    phone { Faker::PhoneNumber.cell_phone }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
  end
end
