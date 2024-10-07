FactoryBot.define do
  factory :messages_package do
    message_template { create(:template_data_container) }

    name { "MyString" }
    status { "initialized" }
  end
end
