# frozen_string_literal: true

RSpec.describe CreateVendorConsumer do
  let(:message) { build(:vendor).attributes }

  subject(:consumer) { described_class.new }

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  it "should have correct queue name" do
    expect(CreateVendorConsumer.get_queue_name).to eq("consumer_user_service_create_vendor")
  end

  it "should enqueue create restaurant jobs" do
    consumer.process(message)
    expect(CreateVendorJob).to have_been_enqueued.with(hash_including({
                                                                        email: message[:email],
                                                                        password: message[:password],
                                                                        first_name: message[:first_name],
                                                                        last_name: message[:last_name],
                                                                        business_name: message[:business_name],
                                                                        phone: message[:phone]
                                                                      }))
  end
end
