# frozen_string_literal: true

RSpec.describe CreateUserExporterJob, type: :job do
  let(:user) { create(:user) }
  let(:sender_id) { Faker::Alphanumeric.alpha }

  subject(:perform) do
    described_class.perform_now(
      user_id: user.id.to_s,
      sender_id: sender_id
    )
  end

  before(:each) do
    allow(Hutch).to receive(:connect)
    allow(Hutch).to receive(:publish)
  end

  it "should have correct queue name" do
    expect(CreateUserExporterJob.queue_name).to eq("user_service_create_user_exporter")
  end

  it "should export user" do
    expect(Hutch).to receive(:publish).with("user.created", { auth_id: user.firebase_id, sender_id: sender_id })

    perform
  end
end
