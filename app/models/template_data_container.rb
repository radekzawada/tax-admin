class TemplateDataContainer < ApplicationRecord
  validates :template_name, :external_spreadsheet_id, presence: true
end
