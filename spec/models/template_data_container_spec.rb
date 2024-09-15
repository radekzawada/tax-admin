require 'rails_helper'

RSpec.describe TemplateDataContainer, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:template_name) }
    it { is_expected.to validate_presence_of(:external_spreadsheet_id) }

    describe 'name' do
      subject(:record) { create(:template_data_container) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end
  end
end
