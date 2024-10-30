class Message < ApplicationRecord
  belongs_to :messages_package_dispatch

  validates :recipient_email, presence: true
  validates :preview, presence: true
  validates :variables, presence: true
end
