require "rails_helper"

RSpec.describe Mailbox::CreateMessageTemplate do
  describe "#call" do
    subject(:call) { command.call(params) }

    let(:command) { described_class.new(google_sheet_client:, google_drive_client:) }

    let(:google_sheet_client) { instance_double(Google::SheetClient) }
    let(:google_drive_client) { instance_double(Google::DriveClient) }

    let(:params) do
      {
        name: "Template data container",
        sheet_name: "Sheet name",
        template: "taxes",
        emails: "test@mail.com test1@mail.com"
      }
    end

    let(:created_container) do
      instance_double(Google::Apis::SheetsV4::Spreadsheet, spreadsheet_id: "123", sheets: [sheet])
    end
    let(:sheet) do
      instance_double(
        Google::Apis::SheetsV4::Sheet,
        properties: instance_double(Google::Apis::SheetsV4::SheetProperties, sheet_id: "1")
      )
    end

    before do
      allow(google_sheet_client).to receive(:create_spreadsheet).and_return(Dry::Monads::Success(created_container))
      allow(google_sheet_client).to receive(:configure_sheet).and_return(Dry::Monads::Success(created_container))
      allow(google_drive_client).to receive(:grant_permissions).and_return(Dry::Monads::Success({}))
    end

    context "when everything is successful" do
      specify do
        expect { call }.to change(MessageTemplate, :count).by(1)
          .and change(MessagesPackage, :count).by(1)
        expect(call).to be_success & be_a(Command::Result) & have_attributes(
          component: :command,
          data: { container: an_instance_of(MessageTemplate), message_package: an_instance_of(MessagesPackage) },
          errors: {}
        )

        expect(MessageTemplate.last).to have_attributes(
          permitted_emails: ["test@mail.com", "test1@mail.com"],
          external_spreadsheet_id: "123",
          template_name: "taxes",
          url: include("https://docs.google.com/spreadsheets/d/"),
          name: "Template data container"
        )

        expect(MessagesPackage.last).to have_attributes(
          name: "Sheet name",
          status: "active",
          message_template: MessageTemplate.last,
          external_sheet_id: "1"
        )

        expect(google_sheet_client).to have_received(:create_spreadsheet)
          .with("Template data container", "Sheet name")
        expect(google_sheet_client).to have_received(:configure_sheet)
          .with("123", sheet, MessageTemplate::TEMPLATES_CONFIGURATION[:taxes])
        expect(google_drive_client).to have_received(:grant_permissions).with("123", email: "test@mail.com")
        expect(google_drive_client).to have_received(:grant_permissions).with("123", email: "test1@mail.com")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          name: nil,
          template: "aaa",
          emails: ""
        }
      end

      specify do
        expect(call).to be_failure & be_a(Command::Result) & have_attributes(
          component: :contract,
          data: {},
          errors: include(:name)
        )
      end
    end

    context "when creating remote container fails" do
      before do
        allow(google_sheet_client)
          .to receive(:create_spreadsheet)
          .and_return(Dry::Monads::Failure("something went wrong"))
      end

      specify do
        expect { call }.not_to change(MessageTemplate, :count)
        expect(call).to be_failure & be_a(Command::Result) & have_attributes(
          component: :command,
          data: {},
          errors: { base: "something went wrong" }
        )
      end
    end

    context "when configuring sheet fails" do
      before do
        allow(google_sheet_client)
          .to receive(:configure_sheet)
          .and_return(Dry::Monads::Failure("something went wrong"))
      end

      specify do
        expect { call }.not_to change(MessageTemplate, :count)
        expect(call).to be_failure & be_a(Command::Result) & have_attributes(
          component: :command,
          data: {},
          errors: { base: "something went wrong" }
        )
      end
    end

    context "when granting access fails" do
      before do
        allow(google_drive_client).to receive(:grant_permissions)
          .and_return(Dry::Monads::Failure("something went wrong"))
      end

      specify do
        expect { call }.not_to change(MessageTemplate, :count)
        expect(call).to be_failure & be_a(Command::Result) & have_attributes(
          component: :command,
          data: {},
          errors: { base: "something went wrong" }
        )
      end
    end
  end
end
