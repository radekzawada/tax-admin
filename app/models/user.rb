class User < ApplicationRecord
  devise :database_authenticatable, :validatable
  validates_presence_of :fullname
end
