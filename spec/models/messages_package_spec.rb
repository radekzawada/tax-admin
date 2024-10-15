require "rails_helper"

RSpec.describe MessagesPackage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:message_template).required }
  end

  describe "validations" do
    subject(:record) { create(:messages_package) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[initialized active processed]) }
    it { is_expected.to validate_presence_of(:external_sheet_id) }
    it { is_expected.to validate_uniqueness_of(:external_sheet_id) }
  end

  describe "scopes" do
    describe ".active" do
      subject(:active) { described_class.active }

      let!(:active_package_1) { create(:messages_package, status: "active") }
      let!(:active_package_2) { create(:messages_package, status: "active") }

      before do
        create(:messages_package, status: "processed")
        create(:messages_package, status: "initialized")
      end

      it { is_expected.to contain_exactly(active_package_1, active_package_2) }
    end

    describe ".processed" do
      subject(:processed) { described_class.processed }

      let!(:processed_package_1) { create(:messages_package, status: "processed") }
      let!(:processed_package_2) { create(:messages_package, status: "processed") }

      before do
        create(:messages_package, status: "active")
        create(:messages_package, status: "initialized")
      end

      it { is_expected.to contain_exactly(processed_package_1, processed_package_2) }
    end
  end
end
