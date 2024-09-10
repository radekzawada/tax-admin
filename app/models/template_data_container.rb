class TemplateDataContainer < ApplicationRecord
  TEMPLATES = %i[taxes insurance].freeze

  validates :template_name, :external_spreadsheet_id, presence: true
end
