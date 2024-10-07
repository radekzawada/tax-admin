class Mailbox::CreateMessageTemplate
  extend Dry::Initializer
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call_command, :grant_access)

  SPREADSHEET_URL_PATTERN = "https://docs.google.com/spreadsheets/d/%<id>s/edit"

  Contract = Dry::Validation.Contract do
    params do
      required(:name).filled(:string)
      required(:sheet_name).filled(:string)
      required(:template).filled(:string)
      required(:emails).maybe(:array).each(:string)

      before(:value_coercer) do |result|
        next result.to_h if result[:emails].nil?

        result.to_h.merge(emails: result[:emails].split.uniq)
      end
    end

    rule(:emails) do
      key.failure(:format?) if value.any? { |email| email !~ URI::MailTo::EMAIL_REGEXP }
    end

    rule(:name) do
      key.failure(:unique?) if MessageTemplate.exists?(name: value)
    end
  end

  option :google_sheet_client, default: proc { Google::SheetClient.default }
  option :google_drive_client, default: proc { Google::DriveClient.default }

  option :contract, default: proc { Contract }

  def self.default
    @default ||= new
  end

  def call(params)
    contract_validation_result = validate_contract(params)
    return result(contract_validation_result, component: :contract) if contract_validation_result.failure?
    data = contract_validation_result.value!

    command_result = call_command(data)

    result(command_result, component: :command)
  end

  private

  def validate_contract(params)
    contract.call(params).then { |result| result.success? ? Success(result.to_h) : Failure(result.errors.to_h) }
  end

  def call_command(data)
    # TODO later extract external calls to separate commands called async
    remote_container = yield create_remote_container(**data)

    yield grant_access(remote_container.spreadsheet_id, emails: data[:emails]) if data[:emails].present?

    container = (yield create_container(data, remote_container))[:container]
    message_package = (yield create_message_package(data, container))[:message_package]

    Success(container:, message_package:)
  end

  def create_remote_container(name:, sheet_name:, **)
    google_sheet_client.create_spreadsheet(name, sheet_name)
  end

  def grant_access(google_object_id, emails:)
    emails.each { |email| yield google_drive_client.grant_permissions(google_object_id, email:) }

    Success()
  end

  def create_container(data, container)
    template_container = MessageTemplate.new(
      external_spreadsheet_id: container.spreadsheet_id,
      template_name: data[:template],
      permitted_emails: data[:emails],
      name: data[:name],
      url: format(SPREADSHEET_URL_PATTERN, id: container.spreadsheet_id)
    )

    template_container.save ? Success(container: template_container) : Failure(template_container.errors.to_hash)
  end

  def create_message_package(data, container)
    message_package = MessagesPackage.new(
      message_template: container,
      name: data[:sheet_name],
      status: :active
    )

    message_package.save ? Success(message_package:) : Failure(message_package.errors.to_hash)
  end

  def result(monad_result, component:)
    data, errors = monad_result.success? ? [ monad_result.value!, {} ] : [ {}, monad_result.failure ]
    errors = { base: errors } unless errors.is_a?(Hash)

    Command::Result.new(component:, errors:, data:)
  end
end
