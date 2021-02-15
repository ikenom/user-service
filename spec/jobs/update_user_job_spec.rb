# frozen_string_literal: true

RSpec.describe UpdateUserJob, type: :job do
  let(:user) { create(:user) }
  let(:name) { Faker::Superhero.name }
  let(:api_key) { Faker::Alphanumeric.alpha }

  subject(:perform) { described_class.perform_now(user_id: user.id, name: name) }

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:update_user)
  end

  it "should call update_user" do
    expect_any_instance_of(FirebaseClient).to receive(:update_user).with({ id_token: user.id_token, name: name }).exactly(1)
    perform
  end
end
