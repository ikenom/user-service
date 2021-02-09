class User
  include Mongoid::Document

  field :firebase_id, type: String
  field :id_token, type: String
  field :refresh_token, type: String
  field :type, type: Symbol

  validates :firebase_id, :id_token, :refresh_token, :type, presence: true
end