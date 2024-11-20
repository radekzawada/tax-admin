require "rails_helper"

RSpec.describe Mailbox::Factories::DraftMessagesFactory do
  describe ".default" do
    subject(:default) { described_class.default }

    it "returns instance of the factory" do
      expect(default).to be_an_instance_of(described_class)
    end
  end

  describe "#from_remote_data" do
    subject(:from_remote_data) { described_class.new.from_remote_data(remote_data, messages_package) }

    let(:messages_package) { instance_double(MessagesPackage, message_template:) }
    let(:message_template) do
      instance_double(
        MessageTemplate,
        data_start_row: 1,
        income_variables: { 0 => "first_name", 1 => "last_name" },
        validations:
      )
    end
    let(:validations) { proc { OpenStruct.new(errors: { email: ["pole nie może być puste"] }) } }
    let(:remote_data) { [%w[John Doe], %w[Jane Smith]] }

    it "returns array of draft messages" do
      expect(from_remote_data).to contain_exactly(
        an_instance_of(Mailbox::DraftMessage) & have_attributes(
          id: be_present,
          index: 2,
          variables: { first_name: "John", last_name: "Doe" },
          errors: { email: ["pole nie może być puste"] }
        ),
        an_instance_of(Mailbox::DraftMessage) & have_attributes(
          id: be_present,
          index: 3,
          variables: { first_name: "Jane", last_name: "Smith" },
          errors: { email: ["pole nie może być puste"] }
        )
      )
    end
  end
end
