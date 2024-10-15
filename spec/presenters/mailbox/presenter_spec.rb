require "rails_helper"

RSpec.describe Mailbox::Presenter do
  subject(:presenter) { described_class.new }

  describe "#message_templates" do
    subject(:message_templates) { presenter.message_templates }

    before do
      create(:message_template, name: "test1", template_name: "taxes")
      create(:message_template, name: "test2", template_name: "insurance")
    end

    specify do
      expect(message_templates).to contain_exactly(
        an_instance_of(Mailbox::Presenter::ContainerData) & have_attributes(name: "test1", template: "Podatki"),
        an_instance_of(Mailbox::Presenter::ContainerData) & have_attributes(name: "test2", template: "Ubezpieczenie")
      )
    end
  end

  describe "#disabled_templates" do
    subject(:disabled_templates) { presenter.disabled_templates }

    before do
      create(:message_template, template_name: "taxes")
      create(:message_template, template_name: "insurance")
    end

    specify do
      expect(disabled_templates).to contain_exactly("taxes", "insurance")
    end
  end

  describe "#default_sheet_name", freeze_time: "2024-10-10" do
    subject(:default_sheet_name) { presenter.default_sheet_name }

    it { is_expected.to eq("Październik 2024") }
  end
end
