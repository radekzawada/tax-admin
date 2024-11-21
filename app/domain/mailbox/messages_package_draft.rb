class Mailbox::MessagesPackageDraft < Dry::Struct
  attribute :variables, Types::Array.of(Types::Coercible::Symbol)
  attribute :mailer_message, Types::Coercible::Symbol
  attribute :package_id, Types::Integer
  attribute :package_name, Types::String
  attribute :template_name, Types::String
  attribute :template_id, Types::Integer
  attribute :draft_messages, Types::Array.of(Mailbox::DraftMessage)
  attribute :external_url, Types::String
end
