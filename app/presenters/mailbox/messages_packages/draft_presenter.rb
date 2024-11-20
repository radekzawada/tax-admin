class Mailbox::MessagesPackages::DraftPresenter
  extend Dry::Initializer

  INCOME_TAX_DATA = %i[income_tax_amount income_tax_type income_tax_period income_tax_payment_deadline].freeze
    VALUE_ADDED_TAX_DATA = %i[value_added_tax_amount value_added_tax_type value_added_tax_period
      value_added_tax_payment_deadline].freeze

  ValidMessage = Struct.new(:id, :email, :full_name, :income_tax_data, :value_added_tax_data, :account_number,
    :preview)
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
      preview = mailbox_mailer.tax_information_message(message).body.to_s

      ValidMessage.new(
        message.id,
        message.variables[:email],
        message.variables[:full_name],
        message.variables.values_at(*INCOME_TAX_DATA).join("/"),
        message.variables.values_at(*VALUE_ADDED_TAX_DATA).map { |v| v.blank? ? "-" : v }.join("/"),
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
