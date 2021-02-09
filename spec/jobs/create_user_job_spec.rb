# frozen_string_literal: true

RSpec.describe CreateUserJob, type: :job do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Alphanumeric.alpha }
  let(:name) { Faker::Name.name }
  let(:type) { :vendor }
  let(:api_key) { Faker::Alphanumeric.alpha }

  let(:payload) do
    {
      "localId" => Faker::Alphanumeric.alpha,
      "idToken" => Faker::Alphanumeric.alpha,
      "refreshToken" => Faker::Alphanumeric.alpha,
    }
  end

  subject(:perform) do
    described_class.perform_now(
      email: email,
      password: password,
      name: name,
      type: type,
      api_key: api_key
    )
  end

  before(:each) do
    allow_any_instance_of(FirebaseClient).to receive(:sign_up).and_return(payload)
    ActiveJob::Base.queue_adapter = :test
  end

  it "should create new user" do
    expect { perform }.to change { User.count }.by(1)
    user = User.last

    expect(user.firebase_id).to eq(payload["localId"])
    expect(user.id_token).to eq(payload["idToken"])
    expect(user.refresh_token).to eq(payload["refreshToken"])
    expect(user.type).to eq(type)
  end

  it "should queue CreateExporterJob" do
    perform
    expect(CreateUserExporterJob).to have_been_enqueued.with(hash_including({
                                                                              firebase_id: payload["localId"],
                                                                              name: name
                                                                            }))
  end

  it "should queue UpdateUserJob" do
    perform
    expect(UpdateUserJob).to have_been_enqueued.with(hash_including({
                                                                      user_id: User.last.id,
                                                                      name: name,
                                                                      api_key: api_key
                                                                    }))
  end
end
