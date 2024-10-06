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

  def create_spreadsheet(title, sheet_title)
    spreadsheet = build_spreadsheet(title, sheet_title)

    created_spreadsheet = google_sheet_service.create_spreadsheet(spreadsheet)

    Success(created_spreadsheet)
  end

  private

  def build_spreadsheet(title, sheet_title)
    Google::Apis::SheetsV4::Spreadsheet.new(
      properties: Google::Apis::SheetsV4::SpreadsheetProperties.new(title:),
      sheets: [
        Google::Apis::SheetsV4::Sheet.new(
          properties: Google::Apis::SheetsV4::SheetProperties.new(title: sheet_title)
        )
      ]
    )
  end
end
