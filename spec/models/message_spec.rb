require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:messages_package_dispatch) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:recipient_email) }
    it { is_expected.to validate_presence_of(:preview) }
    it { is_expected.to validate_presence_of(:variables) }
  end
end
