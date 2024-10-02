class Google::AuthorizationService
  extend Dry::Initializer

  option :google_auth, default: proc { Google::Auth::ServiceAccountCredentials }

  def self.default
    @default ||= new
  end

  def authorization
    @authorization ||= generate_authorization
  end

  private

  def generate_authorization
    google_auth.make_creds(
      json_key_io: File.open(ENV["GOOGLE_CREDENTIALS_PATH"]),
      scope: [ Google::Apis::SheetsV4::AUTH_SPREADSHEETS, Google::Apis::DriveV3::AUTH_DRIVE ]
    )
  end
end
