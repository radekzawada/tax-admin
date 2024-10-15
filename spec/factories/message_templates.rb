FactoryBot.define do
  factory :message_template do
    sequence(:name) { |n| "tamplate_#{n}" }
    template_name { MessageTemplate::TEMPLATES.sample }
    external_spreadsheet_id { SecureRandom.uuid }
    permitted_emails { ["email_1@sample.com", "email_2@sample.com"] }
    sequence(:url) { |n| "www.tamplate_url_#{n}.com" }
  end
end
