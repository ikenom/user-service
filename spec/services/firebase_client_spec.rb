# frozen_string_literal: true

RSpec.describe FirebaseClient, :vcr do
  let(:api_key) { ENV["FIREBASE_API_KEY"] }
  let(:email) { "test@test.com" }
  let(:password) { "password" }
  let(:name) { "John Doe" }

  subject(:client) { FirebaseClient.new(api_key: api_key) }

  describe "#sign_up" do
    it "should create user" do
      response = client.sign_up(email: email, password: password)
      expect(response["localId"]).to be_present
    end

    it "should fail when user already created" do
      expect { client.sign_up(email: email, password: password) }.to raise_error(FirebaseClient::EmailExistsError)
    end

    it "should fail when password is too short" do
      expect { client.sign_up(email: email, password: "1") }.to raise_error(FirebaseClient::PasswordInvalidError)
    end
  end

  describe "#update_user" do
    let(:id_token) { ENV["FIREBASE_USER_ID_TOKEN"] }
    it "should update user name" do
      response = client.update_user(id_token: id_token, name: name)
      expect(response["displayName"]).to eq(name)
    end

    it "should fail when id token invalid" do
      expect { client.update_user(id_token: "foo", name: name) }.to raise_error(FirebaseClient::IDTokenInvalidError)
    end
  end
end
