FactoryBot.define do
  factory :message do
    association :messages_package_dispatch

    recipient_email { "example@example.com" }
    preview { "This is a preview of the message." }
    variables { { key1: "value1", key2: "value2" } }

    sent_at { nil }
  end
end
