class MessagesPackages::Create
  extend Dry::Initializer
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call_command, :create_remote_sheet)

  Contract = Dry::Validation.Contract do
    params do
      required(:name).filled(:string)
      required(:template_id).filled(:integer)
    end

    rule(:name) do
      key.failure(:unique?) if MessagesPackage.exists?(name: value)
    end

    rule(:template_id) do |context:|
      context[:message_template] = MessageTemplate.find_by(id: value)

      key.failure(:not_found?) if context[:message_template].nil?
    end
  end

  option :google_sheet_client, default: proc { Google::SheetClient.default }
  option :contract, default: proc { Contract }

  def self.default
    @default ||= new
  end

  def call(params)
    contract_validation_result = validate_contract(params)

    return result(contract_validation_result, component: :contract) if contract_validation_result.failure?
    data, context = contract_validation_result.value!.values_at(:data, :context)
    command_result = call_command(data, **context)

    result(command_result, component: :command)
  end

  def validate_contract(params)
    result = contract.call(params)
    return Failure(result.errors.to_h) if result.failure?

    Success(data: result.to_h, context: result.context.each.to_h)
  end

  def call_command(data, message_template:, **)
    # TODO later extract external calls to separate commands called async
    remote_sheet = yield create_remote_sheet(message_template, **data)
    yield configure_sheet(message_template, remote_sheet)

    messages_package = (yield create_messages_package(data, message_template, remote_sheet))[:message_package]

    Success(messages_package:)
  end

  def create_remote_sheet(message_template, name:, **)
    google_sheet_client.create_sheet(message_template.external_spreadsheet_id, name)
  end

  def configure_sheet(message_template, remote_sheet)
    template_config = MessageTemplate::TEMPLATES_CONFIGURATION[message_template.template_name.to_sym]

    google_sheet_client.configure_sheet(message_template.external_spreadsheet_id, remote_sheet, template_config)
  end

  def create_messages_package(data, container, remote_sheet)
    message_package = MessagesPackage.new(
      message_template: container,
      name: data[:name],
      status: :active,
      external_sheet_id: remote_sheet.properties.sheet_id
    )

    message_package.save ? Success(message_package:) : Failure(message_package.errors.to_hash)
  end

  def result(monad_result, component:)
    data, errors = monad_result.success? ? [monad_result.value!, {}] : [{}, monad_result.failure]
    errors = { base: errors } unless errors.is_a?(Hash)

    Command::Result.new(component:, errors:, data:)
  end
end
