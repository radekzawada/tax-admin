require 'rails_helper'

RSpec.describe TemplateDataContainer, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:template_name) }
    it { is_expected.to validate_presence_of(:external_spreadsheet_id) }
  end
end
