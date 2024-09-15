class TemplateDataContainer < ApplicationRecord
  TEMPLATES = %i[taxes insurance].freeze

  validates :name, :template_name, :external_spreadsheet_id, presence: true
  validates :name, uniqueness: true
end
