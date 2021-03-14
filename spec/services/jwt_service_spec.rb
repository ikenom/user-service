# frozen_string_literal: true

RSpec.describe JwtService do
  let(:hmac_secret) { Faker::Alphanumeric.alpha }
  let(:payload) { { foo: "foo" } }

  it "should encode payload" do
    token = described_class.encode(payload: payload, hmac_secret: hmac_secret)
    result = JWT.decode(token, hmac_secret, true, { algorithm: 'HS512' })
    decoded_token = result.select { |item| item.include?("foo") }.first

    expect(payload[:foo]).to eq(decoded_token["foo"])
  end

  it "should decode payload and retrieve User" do
    user = create(:user)
    hmac_secret = Faker::Alphanumeric.alpha
    token = JwtService.encode(payload: { refresh_token: user.refresh_token }, hmac_secret: hmac_secret)
    expect_any_instance_of(ExchangeRefreshTokenForUserJob).to receive(:perform_now).and_return(user)

    decoded_user = JwtService.decode_for_user(token: token, hmac_secret: hmac_secret)
    expect(user).to eq(decoded_user)
  end
end
