require "rails_helper"

RSpec.describe MessagesPackages::Create do
  describe "Contract" do
    subject(:contract) { described_class::Contract }

    describe ".call" do
      subject(:call) { contract.call(params) }

      let(:params) do
        {
          name: "sheet",
          template_id: template.id
        }
      end
      let(:template) { create(:message_template) }

      specify do
        expect(call).to be_success & have_attributes(
          to_h: {
            name: "sheet",
            template_id: template.id
          }
        )
      end

      context "with empty params" do
        let(:params) { {} }

        specify do
          expect(call).to be_failure & have_attributes(
            errors: have_attributes(
              to_h: {
                name: ["pole musi być obecne"],
                template_id: ["pole musi być obecne"]
              }
            )
          )
        end
      end

      context "when name is not uniq" do
        let(:params) { { name: "Test" } }

        before { create(:messages_package, name: "Test") }

        it "validates sheet_name uniqueness" do
          expect(call).to be_failure
          expect(call.errors.to_h[:name]).to eq(["wartość musi być unikalna"])
        end
      end

      context "when template does not exist" do
        let(:params) do
          {
            name: "sheet",
            template_id: 0
          }
        end

        it "validates sheet_name uniqueness" do
          expect(call).to be_failure
          expect(call.errors.to_h[:template_id]).to eq(["obiect nie został znaleziony"])
        end
      end
    end
  end

  describe ".default" do
    subject(:default) { described_class.default }

    it { is_expected.to be_a(described_class) }
  end

  describe "#call" do
    subject(:call) { command.call(params) }

    let(:command) { described_class.new(google_sheet_client:) }
    let(:google_sheet_client) { instance_double(Google::SheetClient) }

    let(:params) do
      {
        template_id: template.id,
        name: "sheet"
      }
    end
    let(:template) { create(:message_template, template_name: "taxes", external_spreadsheet_id:) }
    let(:external_spreadsheet_id) { "external_spreadsheet_id" }
    let(:created_sheet) do
      instance_double(
        Google::Apis::SheetsV4::Sheet,
        properties: instance_double(Google::Apis::SheetsV4::SheetProperties, sheet_id: "sheet_id")
      )
    end

    before do
      allow(google_sheet_client).to receive_messages(
        create_sheet: Dry::Monads::Success(created_sheet),
        configure_sheet: Dry::Monads::Success()
      )
    end

    it "creates messages package" do
      expect { call }.to change(MessagesPackage, :count).by(1)
      expect(call).to be_success & have_attributes(
        component: :command,
        data: {
          messages_package: an_instance_of(MessagesPackage) & have_attributes(
            name: "sheet",
            message_template_id: template.id
          )
        }
      )

      expect(google_sheet_client).to have_received(:create_sheet).with("external_spreadsheet_id", "sheet")
      expect(google_sheet_client).to have_received(:configure_sheet).with(
        "external_spreadsheet_id",
        created_sheet,
        MessageTemplate::TEMPLATES_CONFIGURATION[:taxes]
      )
    end
  end
end
