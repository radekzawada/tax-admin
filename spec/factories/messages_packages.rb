FactoryBot.define do
  factory :messages_package do
    message_template { create(:message_template) }

    name { "MyString" }
    status { "initialized" }
    sequence(:external_sheet_id) { |n| "ExternalRef_#{n}" }
  end
end
