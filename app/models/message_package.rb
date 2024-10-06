class MessagePackage < ApplicationRecord
  STATUSES = %w[initialized active processed].freeze
  belongs_to :message_template, class_name: "TemplateDataContainer"

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
