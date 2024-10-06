require "rails_helper"

RSpec.describe TemplateDataContainer, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:message_packages).class_name("MessagePackage") }
  end

  describe "validations" do
    subject(:record) { create(:template_data_container) }

    it { is_expected.to validate_presence_of(:template_name) }
    it { is_expected.to validate_inclusion_of(:template_name).in_array(TemplateDataContainer::TEMPLATES) }
    it { is_expected.to validate_presence_of(:external_spreadsheet_id) }
    it { is_expected.to validate_uniqueness_of(:external_spreadsheet_id) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
  end
end
