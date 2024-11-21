class Repositories::MessagesPackageDraftsRepository
  extend Dry::Initializer
  include Dry::Monads::Do.for(:find)
  include Dry::Monads[:result]

  STORAGE_PREFIX = "MESSAGES_PACKAGE_PREVIEW"

  option :google_sheet_client, default: proc { Google::SheetClient.default }
  option :redis_client, default: proc { Redis.current }
  option :package_drafts_factory, default: proc { Mailbox::Factories::MessagesPackageDraftsFactory.default }

  def self.default
    @default ||= new
  end

  def find(id, fresh: nil)
    storage_key = "#{STORAGE_PREFIX}:#{id}"

    return fetch_records_from_redis(storage_key) if !fresh && redis_client.exists?(storage_key)

    messages_package = MessagesPackage.includes(:message_template).find_by(id:)
    return Failure(:not_found) if messages_package.nil?

    remote_data = yield(fetch_remote_data(messages_package)).values
    return Failure(:no_data) if remote_data.blank?

    draft = package_drafts_factory.from_remote_data(remote_data, messages_package)
    redis_client.set(storage_key, draft.to_json, ex: 1.day.in_seconds)

    Success(data: draft)
  end

  private

  def fetch_records_from_redis(key)
    serialized_data = JSON.parse(redis_client.get(key))
    draft = Mailbox::MessagesPackageDraft.new(serialized_data.deep_symbolize_keys)

    Success(data: draft)
  end

  def fetch_remote_data(messages_package)
    google_sheet_client.read_data(messages_package.external_spreadsheet_id, messages_package.range)
  end
end
