require "rails_helper"

RSpec.describe MessageTemplates::ShowPresenter do
  subject(:presenter) { described_class.new(message_template) }

  describe "#created_at" do
    subject(:created_at) { presenter.created_at }

    let(:message_template) { instance_double(MessageTemplate, created_at: Time.zone.parse("2024-10-10 10:00")) }

    it { is_expected.to eq("2024-10-10 10:00") }
  end

  describe "#active_messages_packages" do
    subject(:active_messages_packages) { presenter.active_messages_packages }

    let(:message_template) { instance_double(MessageTemplate, url: "http://example.com", messages_packages:) }
    let(:messages_package_1) { instance_double(MessagesPackage, id: 1, name: "Test", external_sheet_id: "123") }
    let(:messages_package_2) { instance_double(MessagesPackage, id: 2, name: "Test 2", external_sheet_id: "456") }
    let(:messages_packages) { class_double(MessagesPackage, active: [messages_package_1, messages_package_2]) }

    specify do
      expect(active_messages_packages).to contain_exactly(
        an_instance_of(MessageTemplates::ShowPresenter::ActiveMessagePackage) & have_attributes(
          id: 1,
          name: "Test",
          url: "http://example.com#gid=123"
        ),
        an_instance_of(MessageTemplates::ShowPresenter::ActiveMessagePackage) & have_attributes(
          id: 2,
          name: "Test 2",
          url: "http://example.com#gid=456"
        )
      )
    end
  end
end
