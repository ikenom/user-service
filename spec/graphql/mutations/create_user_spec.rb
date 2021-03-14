# frozen_string_literal: true

RSpec.describe Mutations::CreateUser do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:display_name) { Faker::Internet.name }
  let(:user) { create(:user) }
  let(:token) { Faker::Alphanumeric.alpha }

  subject(:create_user) do
    query_string = <<-GRAPHQL
      mutation($email: String!, $password: String!, $displayName: String!) {
        createUser(input: { email: $email, password: $password, displayName: $displayName }) {
          token
        }
      }
    GRAPHQL

    UserServiceSchema.execute(query_string, variables: {
      email: email,
      password: password,
      displayName: display_name
    })
  end

  before(:each) do
    allow(CreateUserJob).to receive(:perform_now).and_return(user)
    allow(JwtService).to receive(:encode).and_return(Faker::Alphanumeric.alpha).and_return(token)
  end

  it "creates a user" do
    expect(CreateUserJob).to receive(:perform_now).with({
      sender_id: nil,
      email: email,
      password: password,
      display_name: display_name
    }).and_return(user)

    expect(JwtService).to receive(:encode).with(hash_including({
      payload: { refresh_token: user.refresh_token }
    })).and_return(token)

    result = create_user
    expect(result["data"]["createUser"]["token"]).to eq(token)
  end

  it "should contains errors for invalid email" do
    allow(CreateUserJob).to receive(:perform_now).and_raise(FirebaseClient::EmailExistsError)
    result = create_user

    expect(result["errors"].first["extensions"]["code"]).to eq("USER_ALREADY_EXISTS")
  end

  it "should contains errors for invalid password" do
    allow(CreateUserJob).to receive(:perform_now).and_raise(FirebaseClient::PasswordInvalidError)
    result = create_user

    expect(result["errors"].first["extensions"]["code"]).to eq("PASSWORD_INVALID")
  end
end