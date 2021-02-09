# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    firebase_id { Faker::Alphanumeric.alpha }
    id_token { Faker::Alphanumeric.alpha }
    refresh_token { Faker::Alphanumeric.alpha }
    type { :vendor }
  end
end
