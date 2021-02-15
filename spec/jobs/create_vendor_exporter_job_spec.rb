# frozen_string_literal: true

RSpec.describe CreateVendorExporterJob, type: :job do
  let(:vendor) { create(:vendor) }

  subject(:perform) do
    described_class.perform_now(
      user_id: vendor.id.to_s,
    )
  end

  before(:each) do
    allow(Hutch).to receive(:connect)
    allow(Hutch).to receive(:publish)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(CreateVendorExporterJob.queue_name).to eq("user_service_create_vendor_exporter")
  end

  it "should export user" do
    expect(Hutch).to receive(:publish).with("user.vendor.created", {
      user_id: vendor.id.to_s,
      first_name: vendor.first_name,
      last_name: vendor.last_name,
      business_name: vendor.business_name,
      email: vendor.email,
      phone: vendor.phone
                                            })

    perform
  end
end
