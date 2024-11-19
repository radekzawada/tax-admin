class Mailbox::Factories::MessagesPackageDraftsFactory
  extend Dry::Initializer
  include MessagesPackageHelper

  option :draft_messages_factory, default: proc { Mailbox::Factories::DraftMessagesFactory.default }

  def self.default
    @default ||= new
  end

  def from_remote_data(remote_data, message_package)
    messages = draft_messages_factory.from_remote_data(remote_data, message_package)

    Mailbox::MessagesPackageDraft.new(
      package_id: message_package.id,
      package_name: message_package.name,
      template_name: message_package.message_template.name,
      template_id: message_package.message_template.id,
      draft_messages: messages,
      external_url: external_url(message_package.message_template, message_package)
    )
  end
end
