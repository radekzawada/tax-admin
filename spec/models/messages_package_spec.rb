require "rails_helper"

RSpec.describe MessagesPackage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:message_template).required }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[initialized active processed]) }
  end
end