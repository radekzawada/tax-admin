FactoryBot.define do
  factory :message_package do
    message_template { create(:template_data_container) }

    name { "MyString" }
    status { "initialized" }
  end
end
