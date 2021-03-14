module Types
  class AuthType < Types::BaseObject
    field :token, type: String, null: false
  end
end
