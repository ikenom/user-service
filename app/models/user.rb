# frozen_string_literal: true

class User
  include Mongoid::Document

  field :firebase_id, type: String
  field :refresh_token, type: String

  validates :firebase_id, :refresh_token, presence: true
end
