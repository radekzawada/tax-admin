class Mailbox::MessagesPackages::DraftPresenter
  extend Dry::Initializer

  ValidMessage = Struct.new(:id, :email, :full_name, :variables, :account_number, :preview)
  InvalidMessage = Struct.new(:index, :email, :full_name, :errors)

  attr_reader :valid_messages, :invalid_messages

  delegate :package_id, :package_name, :template_id, :template_name, :external_url, to: :draft_package

  param :draft_package, type: Types::Instance(Mailbox::MessagesPackageDraft)
  option :mailbox_mailer, default: proc { MailboxMailer }

  def initialize(...)
    super

    @valid_messages, @invalid_messages = draft_package.draft_messages.partition { |message| message.errors.blank? }
  end

  def valid_drafts
    @valid_drafts ||= valid_messages.map do |message|
      preview = mailbox_mailer.public_send(draft_package.mailer_message, message).body.to_s

      ValidMessage.new(
        message.id,
        message.variables[:email],
        message.variables[:full_name],
        message.variables.except(:email, :full_name, :account_number)
          .values
          .map { |v| v.blank? ? "-" : v }.join("/"),
        message.variables[:account_number],
        preview
      )
    end
  end

  def invalid_drafts
    @invalid_drafts ||= invalid_messages.map do |message|
      InvalidMessage.new(
        message.index,
        message.variables[:email],
        message.variables[:full_name],
        message.errors.map { |k, v|[I18n.t("sheet.headers.#{k}"), v].join(" - ") }
      )
    end
  end
end
