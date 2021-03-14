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

  describe "#login" do
    it "should login user" do
      response = client.login(email: email, password: password)
      expect(response["localId"]).to be_present
    end

    it "should fail when user already created" do
      expect { client.login(email: "foo@shouldnotbehere.net", password: password) }.to raise_error(FirebaseClient::EmailNotFound)
    end

    it "should fail when password is invalid" do
      expect { client.login(email: email, password: "foobar") }.to raise_error(FirebaseClient::PasswordInvalidError)
    end
  end

  describe "#id_token" do
    let(:refresh_token) { "AOvuKvRiXj7i_7t1gMt3BIrqgDwB5-KJVTY6VBWR8ND5no0dysuqgifg1ZvhYf4bHPBxgxa7CJHcjN7motc39309htjCiC1t50JZkPQQfZEYiMINVu8v8aygxLNz3o39Dyg91rwDxpzXSp055QAD57YaqKFENZUC1CM9KTiThcTJsnUqWlJJWoJnQ3ynfFyD4-ncB2aMO-6qutbQ2lLYl-1z9qq-7x4Kow" }

    it "should retrieve id token payload" do
      response = client.id_token(refresh_token: refresh_token)
      expect(response["user_id"]).to be_present
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
