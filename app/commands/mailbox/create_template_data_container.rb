class Mailbox::CreateTemplateDataContainer
  extend Dry::Initializer
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call_command, :grant_access)

  SPREADSHEET_URL_PATTERN = "https://docs.google.com/spreadsheets/d/%<id>s/edit"

  Contract = Dry::Validation.Contract do
    params do
      required(:name).filled(:string)
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
      key.failure(:unique?) if TemplateDataContainer.exists?(name: value)
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
    container = yield create_remote_container(**data)

    yield grant_access(container.spreadsheet_id, emails: data[:emails]) if data[:emails].present?

    create_container(data, container)
  end

  def create_container(data, container)
    template_container = TemplateDataContainer.new(
      external_spreadsheet_id: container.spreadsheet_id,
      template_name: data[:template],
      permitted_emails: data[:emails],
      name: data[:name],
      url: format(SPREADSHEET_URL_PATTERN, id: container.spreadsheet_id)
    )

    template_container.save ? Success(container: template_container) : Failure(template_container.errors.to_hash)
  end

  def create_remote_container(name:, **)
    google_sheet_client.create_spreadsheet(name)
  end

  def grant_access(google_object_id, emails:)
    emails.each { |email| yield google_drive_client.grant_permissions(google_object_id, email:) }

    Success()
  end

  def result(monad_result, component:)
    data, errors = monad_result.success? ? [ monad_result.value!, {} ] : [ {}, monad_result.failure ]
    errors = { base: errors } unless errors.is_a?(Hash)

    Command::Result.new(component:, errors:, data:)
  end
end
