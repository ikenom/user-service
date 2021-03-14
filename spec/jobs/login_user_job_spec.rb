# frozen_string_literal: true

RSpec.describe LoginUserJob, type: :job do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:sender_id) { Faker::Alphanumeric.alpha }
  let(:user) { create(:user) }
  let(:payload) do
    {
      "localId" => user.firebase_id,
      "refreshToken" => Faker::Alphanumeric.alpha,
    }
  end

  subject(:perform) do
    described_class.perform_now(
      email: email,
      password: password,
      sender_id: sender_id
    )
  end

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:login).and_return(payload)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(LoginUserJob.queue_name).to eq("user_service_login_user")
  end

  it "should login user" do
    perform
    updated_user = User.last
    expect(updated_user.refresh_token).not_to eq(user.refresh_token)
  end

  it "should return logged in user" do
    user = perform
    expect(user).to eq(User.last)
  end
end
