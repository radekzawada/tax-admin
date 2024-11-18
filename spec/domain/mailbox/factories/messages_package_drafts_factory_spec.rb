require "rails_helper"

RSpec.describe Mailbox::Factories::MessagesPackageDraftsFactory do
  describe ".default" do
    subject(:default) { described_class.default }

    it "returns instance of the factory" do
      expect(default).to be_an_instance_of(described_class) & have_attributes(
        draft_messages_factory: Mailbox::Factories::DraftMessagesFactory.default
      )
    end
  end

  describe "#from_remote_data" do
    subject(:from_remote_data) { factory.from_remote_data(remote_data, messages_package) }

    let(:factory) { described_class.new(draft_messages_factory:) }
    let(:draft_messages_factory) { instance_double(Mailbox::Factories::DraftMessagesFactory) }

    let(:remote_data) { [%w[John Doe], %w[Jane Smith]] }
    let(:messages_package) do
      instance_double(
        MessagesPackage,
        message_template:,
        id: 1,
        name: "message package 1",
        external_sheet_id: "sheet_id"
      )
    end
    let(:message_template) do
      instance_double(MessageTemplate, id: 2, name: "message template name", url: "www.example.com")
    end

    let(:draft_messages) do
      [
        instance_double(Mailbox::DraftMessage, is_a?: true),
        instance_double(Mailbox::DraftMessage, is_a?: true)
      ]
    end

    before do
      allow(draft_messages_factory).to receive(:from_remote_data).and_return(draft_messages)
    end

    it "returns messages package draft" do
      expect(from_remote_data).to be_an_instance_of(Mailbox::MessagesPackageDraft) & have_attributes(
        package_id: 1,
        package_name: "message package 1",
        template_name: "message template name",
        template_id: 2,
        draft_messages:,
        external_url: "www.example.com#gid=sheet_id"
      )
    end
  end
end
