# frozen_string_literal: true

class Vendor < User
  field :business_name, type: String
  field :email, type: String
  field :phone, type: String
  field :first_name, type: String
  field :last_name, type: String

  validates :business_name, :email, :phone, :first_name, :last_name, presence: true
end
