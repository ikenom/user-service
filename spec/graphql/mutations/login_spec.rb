# frozen_string_literal: true

RSpec.describe Mutations::CreateUser do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:display_name) { Faker::Internet.name }
  let(:user) { create(:user) }
  let(:token) { Faker::Alphanumeric.alpha }

  subject(:create_user) do
    query_string = <<-GRAPHQL
      mutation($email: String!, $password: String!) {
        login(input: { email: $email, password: $password}) {
          token
        }
      }
    GRAPHQL

    UserServiceSchema.execute(query_string, variables: {
      email: email,
      password: password
    })
  end

  before(:each) do
    allow(LoginUserJob).to receive(:perform_now).and_return(user)
    allow(JwtService).to receive(:encode).and_return(Faker::Alphanumeric.alpha).and_return(token)
  end

  it "logs in" do
    expect(LoginUserJob).to receive(:perform_now).with({
      sender_id: nil,
      email: email,
      password: password
    }).and_return(user)

    expect(JwtService).to receive(:encode).with(hash_including({
      payload: { refresh_token: user.refresh_token }
    })).and_return(token)

    result = create_user
    expect(result["data"]["login"]["token"]).to eq(token)
  end

  it "should contains errors for invalid email" do
    allow(LoginUserJob).to receive(:perform_now).and_raise(FirebaseClient::EmailNotFound)
    result = create_user

    expect(result["errors"].first["extensions"]["code"]).to eq("EMAIL_NOT_FOUND")
  end

  it "should contains errors for invalid password" do
    allow(LoginUserJob).to receive(:perform_now).and_raise(FirebaseClient::PasswordInvalidError)
    result = create_user

    expect(result["errors"].first["extensions"]["code"]).to eq("PASSWORD_INVALID")
  end
end