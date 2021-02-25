# frozen_string_literal: true

RSpec.describe CreateUserJob, type: :job do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:display_name) { Faker::Name.name }
  let(:sender_id) { Faker::Alphanumeric.alpha }


  let(:payload) do
    {
      "localId" => Faker::Alphanumeric.alpha,
      "idToken" => Faker::Alphanumeric.alpha,
      "refreshToken" => Faker::Alphanumeric.alpha,
    }
  end
  let(:user_payload) { build(:user) }

  subject(:perform) do
    described_class.perform_now(
      email: email,
      password: password,
      display_name: display_name,
      sender_id: sender_id
    )
  end

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:sign_up).and_return(payload)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(CreateUserJob.queue_name).to eq("user_service_create_user")
  end

  it "should create new user" do
    expect { perform }.to change { User.count }.by(1)
    user = User.last

    expect(user.firebase_id).to eq(payload["localId"])
    expect(user.id_token).to eq(payload["idToken"])
    expect(user.refresh_token).to eq(payload["refreshToken"])
  end

  it "should queue CreateExporterJob" do
    perform
    expect(CreateUserExporterJob).to have_been_enqueued.with({ user_id: User.last.id.to_s, sender_id: sender_id })
  end

  it "should queue UpdateUserJob" do
    perform
    expect(UpdateUserJob).to have_been_enqueued.with({
                                                       user_id: User.last.id,
                                                       name: display_name
                                                     })
  end
end
