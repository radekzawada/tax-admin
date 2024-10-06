require "rails_helper"

RSpec.describe Mailbox::Presenter do
  let(:presenter) { described_class.new }

  describe "#template_data_containers" do
    subject(:template_data_containers) { presenter.template_data_containers }

    before do
      create(:template_data_container, name: "test1", template_name: "taxes")
      create(:template_data_container, name: "test2", template_name: "insurance")
    end

    specify do
      expect(template_data_containers).to contain_exactly(
        an_instance_of(Mailbox::Presenter::ContainerData) & have_attributes(name: "test1", template: "Podatki"),
        an_instance_of(Mailbox::Presenter::ContainerData) & have_attributes(name: "test2", template: "Ubezpieczenie")
      )
    end
  end

  describe "#disabled_templates" do
    subject(:disabled_templates) { presenter.disabled_templates }

    before do
      create(:template_data_container, template_name: "taxes")
      create(:template_data_container, template_name: "insurance")
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
