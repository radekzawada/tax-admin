FactoryBot.define do
  factory :user do
    fullname { "John Doe" }
    sequence(:email) { |n| "john.doe#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
