require "rails_helper"

RSpec.describe MessagesPackages::ReadRemoteData do
  describe "Contract" do
    subject(:contract) { described_class::Contract }

    describe ".call" do
      subject(:call) { contract.call(params) }

      let(:params) { { id: messages_package.id } }
      let(:messages_package) { create(:messages_package) }

      specify do
        expect(call).to be_success & have_attributes(
          to_h: { id: messages_package.id }
        )
        expect(call.context.each.to_h).to eq({ messages_package: })
      end

      context "with empty params" do
        let(:params) { {} }

        it "validates presence of id" do
          expect(call).to be_failure & have_attributes(
            errors: have_attributes(
              to_h: { id: ["pole musi być obecne"] }
            )
          )
        end
      end

      context "when messages_package does not exist" do
        let(:params) { { id: 0 } }

        it "validates presence of messages_package" do
          expect(call).to be_failure & have_attributes(
            errors: have_attributes(
              to_h: { id: ["nie istnieje"] }
            )
          )
        end
      end
    end
  end

  describe ".default" do
    subject(:default) { described_class.default }

    it "returns instance of the command" do
      expect(default).to be_an_instance_of(described_class) & have_attributes(
        contract: described_class::Contract,
        google_sheet_client: Google::SheetClient.default,
        draft_messages_factory: Mailbox::Factories::DraftMessagesFactory.default
      )
    end
  end

  describe "#call" do
    subject(:call) { command.call(params) }

    let(:params) { { id: messages_package.id } }

    let(:command) { described_class.new(google_sheet_client:, draft_messages_factory:) }
    let(:google_sheet_client) { instance_double(Google::SheetClient) }
    let(:draft_messages_factory) { instance_double(Mailbox::Factories::DraftMessagesFactory) }

    let(:messages_package) do
      instance_double(MessagesPackage, id: 123, external_spreadsheet_id: "spreadsheet_id", range: "range")
    end
    let(:draft_messages) { [instance_double(Mailbox::DraftMessage)] }

    before do
      allow(google_sheet_client).to receive(:read_data).and_return(Dry::Monads::Success("data"))
      allow(draft_messages_factory).to receive(:from_remote_data).and_return(draft_messages)
      allow(MessagesPackage).to receive(:includes).with(:message_template).and_return(MessagesPackage)
      allow(MessagesPackage).to receive(:find_by).with(id: messages_package.id).and_return(messages_package)
    end

    it "reads data from remote sheet and returns draft messages" do
      expect(call).to be_success & have_attributes(
        data: { messages: draft_messages }
      )

      expect(google_sheet_client).to have_received(:read_data).with("spreadsheet_id", "range")
      expect(draft_messages_factory).to have_received(:from_remote_data).with("data", messages_package)
    end

    context "when reading remote data went wrong" do
      before do
        allow(google_sheet_client).to receive(:read_data).and_return(Dry::Monads::Failure("error"))
      end

      it "returns failure" do
        expect(call).to be_failure & have_attributes(
          errors: { base: "error" },
          component: :command
        )
      end
    end
  end
end
