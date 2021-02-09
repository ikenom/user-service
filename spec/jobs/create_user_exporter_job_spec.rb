# frozen_string_literal: true

RSpec.describe CreateUserExporterJob, type: :job do
  let(:user_id) { Faker::Alphanumeric.alpha }
  let(:name) { Faker::Name.name }
  let(:type) { :vendor }

  subject(:perform) do
    described_class.perform_now(
      user_id: user_id,
      name: name,
      type: type
    )
  end

  before(:each) do
    allow(Hutch).to receive(:connect)
    allow(Hutch).to receive(:publish)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should export user" do
    expect(Hutch).to receive(:publish).with("user.created", {
      user: {
        id: user_id,
        name: name,
        type: type
      }
    })

    perform
  end
end
