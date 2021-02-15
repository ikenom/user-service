# frozen_string_literal: true

RSpec.describe Vendor, type: :model do
  subject { build(:vendor) }

  describe "validations" do
    it { is_expected.to be_mongoid_document }
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:business_name) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
  end
end
