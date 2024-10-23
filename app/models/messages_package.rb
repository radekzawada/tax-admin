class MessagesPackage < ApplicationRecord
  STATUSES = %w[initialized active processed].freeze

  belongs_to :message_template

  validates :name, presence: true
  validates :name, uniqueness: { scope: :message_template_id }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :external_sheet_id, presence: true, uniqueness: true

  scope :active, -> { where(status: :active) }
  scope :processed, -> { where(status: :processed) }
end
