class MessagesPackageDispatch < ApplicationRecord
  STATUSES = %w[loaded dispatched delivered].freeze

  belongs_to :messages_package
  belongs_to :data_loaded_by, class_name: "User", optional: true
  belongs_to :dispatched_by, class_name: "User", optional: true

  validates :status, presence: true, inclusion: { in: STATUSES }
end
