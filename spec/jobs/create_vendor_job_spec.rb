# frozen_string_literal: true

RSpec.describe CreateVendorJob, type: :job do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:type) { :vendor }
  let(:api_key) { Faker::Alphanumeric.alpha }

  let(:payload) do
    {
      "localId" => Faker::Alphanumeric.alpha,
      "idToken" => Faker::Alphanumeric.alpha,
      "refreshToken" => Faker::Alphanumeric.alpha,
    }
  end
  let(:vendor_payload) { build(:vendor) }

  subject(:perform) do
    described_class.perform_now(
      email: email,
      password: password,
      first_name: vendor_payload.first_name,
      last_name: vendor_payload.last_name,
      business_name: vendor_payload.business_name,
      phone: vendor_payload.phone
    )
  end

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:sign_up).and_return(payload)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(CreateVendorJob.queue_name).to eq("user_service_create_vendor")
  end

  it "should create new vendor" do
    expect { perform }.to change { Vendor.count }.by(1)
    vendor = Vendor.last

    expect(vendor.firebase_id).to eq(payload["localId"])
    expect(vendor.id_token).to eq(payload["idToken"])
    expect(vendor.refresh_token).to eq(payload["refreshToken"])

    expect(vendor.business_name).to eq(vendor_payload.business_name)
    expect(vendor.first_name).to eq(vendor_payload.first_name)
    expect(vendor.last_name).to eq(vendor_payload.last_name)
    expect(vendor.phone).to eq(vendor_payload.phone)
  end

  it "should queue CreateExporterJob" do
    perform
    expect(CreateVendorExporterJob).to have_been_enqueued.with({ user_id: Vendor.last.id.to_s })
  end

  it "should queue UpdateUserJob" do
    perform
    expect(UpdateUserJob).to have_been_enqueued.with({
                                                       user_id: Vendor.last.id,
                                                       name: "#{vendor_payload.first_name} #{vendor_payload.last_name}"
                                                     })
  end
end
