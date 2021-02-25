# frozen_string_literal: true

class User
  include Mongoid::Document

  field :firebase_id, type: String
  field :id_token, type: String
  field :refresh_token, type: String

  validates :firebase_id, :id_token, :refresh_token, presence: true
end
