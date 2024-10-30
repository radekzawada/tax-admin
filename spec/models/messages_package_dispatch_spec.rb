require "rails_helper"

RSpec.describe MessagesPackageDispatch, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:messages_package) }
    it { is_expected.to belong_to(:data_loaded_by).class_name("User").optional }
    it { is_expected.to belong_to(:dispatched_by).class_name("User").optional }
  end

  describe "validations" do
    subject(:record) { create(:messages_package_dispatch) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[loaded dispatched delivered]) }
  end
end
