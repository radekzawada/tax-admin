class Google::SheetClient
  extend Dry::Initializer
  include Dry::Monads[:result]

  GAP = Google::Apis::SheetsV4::CellData.new(
    user_entered_value: Google::Apis::SheetsV4::ExtendedValue.new(string_value: nil)
  )
  HEADER_CELL_FORMAT = Google::Apis::SheetsV4::CellFormat.new(
    horizontal_alignment: "CENTER",
    text_format: Google::Apis::SheetsV4::TextFormat.new(bold: true)
  )
  UPDATE_FORMAT_AND_VALUE_FIELDS = "userEnteredFormat(horizontalAlignment,backgroundColor,textFormat),userEnteredValue"
  MERGE_ALL_TYPE = "MERGE_ALL"

  option :google_sheet_service
  option :requests_factory, default: proc { Google::SheetClient::RequestsFactory.new }

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

  def configure_sheet(spreadsheet, sheet, configuration)
    requests = requests_factory.from_template_configuration(sheet, configuration)
    batch_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests:)

    google_sheet_service.batch_update_spreadsheet(spreadsheet.spreadsheet_id, batch_request)

    Success()
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
