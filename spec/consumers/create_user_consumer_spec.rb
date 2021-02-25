# frozen_string_literal: true

RSpec.describe CreateUserConsumer do
  let(:message) { build(:user).attributes }

  subject(:consumer) { described_class.new }

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(CreateUserConsumer.get_queue_name).to eq("consumer_user_service_create_user")
  end

  it "should enqueue create user job" do
    consumer.process(message)
    expect(CreateUserJob).to have_been_enqueued.with({
                                                       email: message[:email],
                                                       password: message[:password],
                                                       sender_id: message[:sender_id],
                                                       display_name: message[:display_name]
                                                     })
  end
end
