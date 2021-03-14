# frozen_string_literal: true

RSpec.describe PublishJob, type: :job do
  let(:user) { create(:user) }
  let(:sender_id) { Faker::Alphanumeric.alpha }

  subject(:perform) do
    described_class.perform_now(
      user_id: user.id.to_s,
      sender_id: sender_id,
      queue_name: "user.created"
    )
  end

  before(:each) do
    allow(Hutch).to receive(:connect)
    allow(Hutch).to receive(:publish)
  end

  it "should have correct queue name" do
    expect(PublishJob.queue_name).to eq("user_service_publish")
  end

  it "should export user" do
    expect(Hutch).to receive(:publish).with("user.created", { user_id: user.id.to_s, sender_id: sender_id })

    perform
  end
end
