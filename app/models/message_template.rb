class MessageTemplate < ApplicationRecord
  TEMPLATES = %w[taxes insurance].freeze

  TEMPLATES_CONFIGURATION = {
    taxes: MessageTemplate::Taxes::CONFIGURATION,
    insurance: MessageTemplate::Insurance::CONFIGURATION
  }

  validates :external_spreadsheet_id, uniqueness: true, presence: true
  validates :name, uniqueness: true, presence: true
  validates :template_name, presence: true, inclusion: { in: TEMPLATES }
  validates :url, presence: true

  has_many :messages_packages

  delegate :income_variables, :data_start_row, :validations, to: :template_configuration

  def template_configuration
    TEMPLATES_CONFIGURATION[template_name.to_sym]
  end
end
