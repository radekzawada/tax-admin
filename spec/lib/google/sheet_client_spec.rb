require "rails_helper"

RSpec.describe Google::SheetClient do
  describe ".default" do
    subject(:default) { described_class.default }

    specify do
      expect(default).to be_an_instance_of(described_class) & have_attributes(
        google_sheet_service: an_instance_of(Google::Apis::SheetsV4::SheetsService)
      )
    end
  end

  describe "#create_spreadsheet" do
    subject(:create_spreadsheet) { sheet_client.create_spreadsheet(title, sheet_title) }

    let(:sheet_client) { described_class.new(google_sheet_service:) }
    let(:google_sheet_service) { instance_double(Google::Apis::SheetsV4::SheetsService) }
    let(:title) { "Spreadsheet title" }
    let(:sheet_title) { "Sheet title" }
    let(:spreadsheet) { instance_double(Google::Apis::SheetsV4::Spreadsheet) }

    before do
      allow(google_sheet_service).to receive(:create_spreadsheet).and_return(spreadsheet)
    end

    it "creates a spreadsheet" do
      expect(create_spreadsheet).to be_success & have_attributes(value!: spreadsheet)

      expect(google_sheet_service).to have_received(:create_spreadsheet).with(
        an_instance_of(Google::Apis::SheetsV4::Spreadsheet) & have_attributes(
          properties: an_instance_of(Google::Apis::SheetsV4::SpreadsheetProperties) & have_attributes(title:),
          sheets: [
            an_instance_of(Google::Apis::SheetsV4::Sheet) & have_attributes(
              properties: an_instance_of(Google::Apis::SheetsV4::SheetProperties) & have_attributes(title: sheet_title)
            )
          ]
        )
      )
    end
  end

  describe "#create_sheet" do
    subject(:create_sheet) { sheet_client.create_sheet(spreadsheet_id, sheet_title) }

    let(:sheet_client) { described_class.new(google_sheet_service:, requests_factory:) }
    let(:google_sheet_service) { instance_double(Google::Apis::SheetsV4::SheetsService) }
    let(:requests_factory) { instance_double(Google::SheetClient::RequestsFactory) }

    let(:spreadsheet_id) { "spreadsheet_id" }
    let(:sheet_title) { "Sheet title" }

    let(:new_sheet_request) { instance_double(Google::Apis::SheetsV4::Request) }
    let(:create_sheet_response) do
      instance_double(
        Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse,
        replies: [instance_double(Google::Apis::SheetsV4::Response, add_sheet: new_sheet)]
      )
    end
    let(:new_sheet) { instance_double(Google::Apis::SheetsV4::Sheet) }

    before do
      allow(requests_factory).to receive(:new_sheet_request).and_return(new_sheet_request)
      allow(google_sheet_service).to receive(:batch_update_spreadsheet).and_return(create_sheet_response)
    end

    it "creates remote sheet" do
      expect(create_sheet).to be_success & have_attributes(value!: new_sheet)

      expect(requests_factory).to have_received(:new_sheet_request).with(sheet_title)
      expect(google_sheet_service).to have_received(:batch_update_spreadsheet).with(
        spreadsheet_id,
        an_instance_of(Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest) & have_attributes(
          requests: [new_sheet_request]
        )
      )
    end
  end

  describe "#configure_sheet" do
    subject(:configure_sheet) { sheet_client.configure_sheet(spreadsheet_id, sheet, configuration) }

    let(:sheet_client) { described_class.new(google_sheet_service:, requests_factory:) }
    let(:google_sheet_service) { instance_double(Google::Apis::SheetsV4::SheetsService) }
    let(:requests_factory) { instance_double(Google::SheetClient::RequestsFactory) }

    let(:spreadsheet_id) { "spreadsheet_id" }
    let(:sheet) { instance_double(Google::Apis::SheetsV4::Sheet) }
    let(:configuration) { instance_double(MessageTemplate::Configuration) }
    let(:requests) { [instance_double(Google::Apis::SheetsV4::Request)] }

    before do
      allow(requests_factory).to receive(:from_template_configuration).and_return(requests)
      allow(google_sheet_service).to receive(:batch_update_spreadsheet)
    end

    it "configures a sheet" do
      expect(configure_sheet).to be_success

      expect(requests_factory).to have_received(:from_template_configuration).with(sheet, configuration)
      expect(google_sheet_service).to have_received(:batch_update_spreadsheet).with(
        "spreadsheet_id",
        an_instance_of(Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest) & have_attributes(requests:)
      )
    end
  end
end
