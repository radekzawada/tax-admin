class MessagesPackage < ApplicationRecord
  STATUSES = %w[initialized active processed].freeze

  delegate :external_spreadsheet_id, to: :message_template

  belongs_to :message_template
  has_many :messages_package_dispatches, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :message_template_id }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :external_sheet_id, presence: true, uniqueness: true

  scope :active, -> { where(status: :active) }
  scope :processed, -> { where(status: :processed) }

  def range
    starting_row = message_template.data_start_row

    "'#{name}'!#{starting_row + 1}:1000"
  end
end
