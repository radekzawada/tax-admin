class MessagesPackage < ApplicationRecord
  STATUSES = %w[initialized active processed].freeze
  belongs_to :message_template

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :external_sheet_id, presence: true, uniqueness: true
end
