class Google::SheetClient
  extend Dry::Initializer
  include Dry::Monads[:result]

  option :google_sheet_service

  def self.default
    @default ||= begin
      google_sheet_service = Google::Apis::SheetsV4::SheetsService.new
      google_sheet_service.client_options.application_name = AppConstants::APP_NAME
      google_sheet_service.authorization = Google::AuthorizationService.default.authorization

      new(google_sheet_service:)
    end
  end

  def create_spreadsheet(title)
    spreadsheet = Google::Apis::SheetsV4::Spreadsheet.new(
      properties: { title: }
    )

    created_spreadsheet = google_sheet_service.create_spreadsheet(spreadsheet)

    Success(created_spreadsheet)
  end
end
