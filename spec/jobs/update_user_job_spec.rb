# frozen_string_literal: true

RSpec.describe UpdateUserJob, type: :job do
  let(:user) { create(:user) }
  let(:name) { Faker::Superhero.name }
  let(:api_key) { Faker::Alphanumeric.alpha }
  let(:id_token) { Faker::Alphanumeric.alpha }

  subject(:perform) { described_class.perform_now(id_token: id_token, name: name) }

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:update_user)
  end

  it "should call update_user" do
    expect_any_instance_of(FirebaseClient).to receive(:update_user).with({ id_token: id_token, name: name }).exactly(1)
    perform
  end
end
