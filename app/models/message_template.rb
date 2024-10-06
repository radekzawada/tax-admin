class MessageTemplate < ApplicationRecord
  TEMPLATES = %w[taxes insurance].freeze

  validates :external_spreadsheet_id, uniqueness: true, presence: true
  validates :name, uniqueness: true, presence: true
  validates :template_name, presence: true, inclusion: { in: TEMPLATES }
  validates :url, presence: true

  has_many :message_packages
end
