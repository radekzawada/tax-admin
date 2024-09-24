class Google::DriveClient
  extend Dry::Initializer
  include Dry::Monads[:result]

  USER_TYPE = "user".freeze

  WRITE_ROLE = "writer".freeze
  READ_ROLE = "reader".freeze

  option :google_drive_service

  def self.default
    @default ||= begin
      google_drive_service = Google::Apis::DriveV3::DriveService.new
      google_drive_service.client_options.application_name = AppConstants::APP_NAME
      google_drive_service.authorization = Google::AuthorizationService.default.authorization

      new(google_drive_service:)
    end
  end

  def grant_permissions(google_object_id, email:, role: WRITE_ROLE, type: USER_TYPE)
    permission = Google::Apis::DriveV3::Permission.new(email_address: email, type:, role:)

    google_drive_service.create_permission(google_object_id, permission)

    Success()
  end
end
