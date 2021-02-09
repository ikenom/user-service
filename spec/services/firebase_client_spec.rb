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
    let(:id_token) { "eyJhbGciOiJSUzI1NiIsImtpZCI6IjJjMmVkODQ5YThkZTI3ZTI0NjFlNGJjM2VmMDZhYzdhYjc4OGQyMmIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vb3Bwb3J0dW5pdHktc2l0ZSIsImF1ZCI6Im9wcG9ydHVuaXR5LXNpdGUiLCJhdXRoX3RpbWUiOjE2MTI4NDAwNTMsInVzZXJfaWQiOiJaalA4ZWxLMDNFTjJYVWUwOENhTmY3cHBnVkcyIiwic3ViIjoiWmpQOGVsSzAzRU4yWFVlMDhDYU5mN3BwZ1ZHMiIsImlhdCI6MTYxMjg0MDA1MywiZXhwIjoxNjEyODQzNjUzLCJlbWFpbCI6InRlc3QzQHRlc3QuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInRlc3QzQHRlc3QuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.4W9cPl21EWjs5HCcM6k8iEC_kwuc5kDBazafnjUVP8WlbS32LvTtO1TyRD_kcm7hOsXWND2QrwB-y8TgD8ZL8xHM6C4WOy7ziPUHoCfsgUOqg5NnYkhftKKa51K-G_rjm90R4VanCNbjtxh5RYYpNthuQC2QdC5MYWHnoailmzRrXjSgCQRxWC_P-S-nXfab25-pNHRym_oX5b4tF2IF5ApdEe3-klYerrgnbMJG5TD12oxf5GwUNVCaJ-o4F67tEzW_LezBzx4zT-XIWpoRqHT0lmKSO9rj_zdfzr8w_5q4AJOj_J1F6qQ4h2lxrRjMFy6IkljTUvqe6jQppLovgQ" }
    it "should update user name" do
      response = client.update_user(id_token: id_token, name: name)
      expect(response["displayName"]).to eq(name)
    end

    it "should fail when id token invalid" do
      expect { client.update_user(id_token: "foo", name: name) }.to raise_error(FirebaseClient::IDTokenInvalidError)
    end
  end
end
