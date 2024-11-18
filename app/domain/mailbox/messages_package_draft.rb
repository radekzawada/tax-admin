class Mailbox::MessagesPackageDraft < Dry::Struct
  attribute :package_id, Types::Integer
  attribute :package_name, Types::String
  attribute :template_name, Types::String
  attribute :template_id, Types::Integer
  attribute :draft_messages, Types::Array.of(Mailbox::DraftMessage)
  attribute :external_url, Types::String
end
