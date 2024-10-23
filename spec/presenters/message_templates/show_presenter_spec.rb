require "rails_helper"

RSpec.describe MessageTemplates::ShowPresenter do
  subject(:presenter) { described_class.new(message_template) }

  describe "#created_at" do
    subject(:created_at) { presenter.created_at }

    let(:message_template) do
      instance_double(MessageTemplate, created_at: Time.zone.parse("2024-10-10 10:00"), is_a?: true)
    end

    it { is_expected.to eq("2024-10-10 10:00") }
  end

  describe "#active_messages_packages" do
    subject(:active_messages_packages) { presenter.active_messages_packages }

    let(:message_template) do
      instance_double(MessageTemplate, url: "http://example.com", messages_packages:, is_a?: true)
    end
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

  describe "#processed_messages_packages" do
    subject(:processed_messages_packages) { presenter.processed_messages_packages }

    let(:message_template) do
      instance_double(
        MessageTemplate,
        messages_packages: class_double(MessagesPackage, processed: [messages_package1, messages_package2]),
        is_a?: true
      )
    end
    let(:messages_package1) { instance_double(MessagesPackage, status: "processed") }
    let(:messages_package2) { instance_double(MessagesPackage, status: "processed") }

    it { is_expected.to contain_exactly(messages_package1, messages_package2) }
  end

  describe "#default_new_package_name", freeze_time: "2024-10-11" do
    subject(:default_new_package_name) { presenter.default_new_package_name }

    let(:message_template) { instance_double(MessageTemplate, is_a?: true) }

    it { is_expected.to eq("Październik 2024") }
  end
end
