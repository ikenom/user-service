# frozen_string_literal: true

RSpec.describe ExchangeRefreshTokenForUserJob, type: :job do
  let(:user) { create(:user) }
  let(:refresh_token) { Faker::Alphanumeric.alpha }
  let(:payload) { {
    "user_id" => user.firebase_id
  } }

  subject(:perform) { described_class.perform_now(refresh_token: refresh_token) }

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:id_token)
  end

  it "should exchange refresh token for user" do
    expect_any_instance_of(FirebaseClient).to receive(:id_token).with({ refresh_token: refresh_token}).and_return(payload)
    decoded_user = perform

    expect(user).to eq(decoded_user)
  end
end
