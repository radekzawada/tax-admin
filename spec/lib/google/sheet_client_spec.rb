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
end
