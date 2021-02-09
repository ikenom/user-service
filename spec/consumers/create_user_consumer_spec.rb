# frozen_string_literal: true

RSpec.describe CreateUserConsumer do
  let(:message) do
    {
      email: Faker::Alphanumeric.alpha,
      password: Faker::Alphanumeric.alpha,
      name: Faker::Name.name,
      type: :vendor
    }
  end
  subject(:consumer) { described_class.new }

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  it "should enqueue create restaurant jobs" do
    consumer.process(message)
    expect(CreateUserJob).to have_been_enqueued.with(hash_including({
      email: message[:email],
      password: message[:password],
      name: message[:name],
      type: message[:type]
    }))
  end
end
