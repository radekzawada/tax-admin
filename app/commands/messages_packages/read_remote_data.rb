class MessagesPackages::ReadRemoteData
  extend Dry::Initializer
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call_command)

  Contract = Dry::Validation.Contract do
    params do
      required(:id).filled(:integer)
    end

    rule(:id) do |context:|
      context[:messages_package] = MessagesPackage.includes(:message_template).find_by(id: value)

      key.failure(:not_found?) if context[:messages_package].nil?
    end
  end

  option :contract, default: proc { Contract }
  option :google_sheet_client, default: proc { Google::SheetClient.default }
  option :draft_messages_factory, default: proc { Mailbox::Factories::DraftMessagesFactory.default }

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

  private

  def validate_contract(params)
    result = contract.call(params)
    return Failure(result.errors.to_h) if result.failure?

    Success(data: result.to_h, context: result.context.each.to_h)
  end

  def call_command(*, messages_package:, **)
    result = yield google_sheet_client.read_data(
      messages_package.external_spreadsheet_id,
      messages_package.range
    )
    draft_messages = draft_messages_factory.from_remote_data(result, messages_package)

    Success({ messages: draft_messages })
  end

  def result(monad_result, component:)
    data, errors = monad_result.success? ? [monad_result.value!, {}] : [{}, monad_result.failure]
    errors = { base: errors } unless errors.is_a?(Hash)

    Command::Result.new(component:, errors:, data:)
  end
end
