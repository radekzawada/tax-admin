require "rails_helper"

RSpec.describe Mailbox::MessagesPackages::DraftPresenter do
  subject(:presenter) { described_class.new(draft_package, mailbox_mailer:) }

  let(:draft_package) { instance_double(Mailbox::MessagesPackageDraft, draft_messages:, is_a?: true) }
  let(:mailbox_mailer) { class_double(MailboxMailer, tax_information_message: message) }
  let(:message) { instance_double(Mail::Message, body: "mail body to render") }
  let(:draft_messages) { [draft_message1, draft_message2, draft_message3, draft_message4] }

  let(:draft_message1) do
    instance_double(
      Mailbox::DraftMessage,
      id: 1,
      errors: {},
      variables: {
        email: "test1@email.com",
        full_name: "John Doe",
        income_tax_amount: "1000 zł",
        income_tax_type: "PIT-36",
        income_tax_period: "2021",
        income_tax_payment_deadline: "2021-05-31",
        account_number: "1234567890"
      }
    )
  end

  let(:draft_message2) do
    instance_double(
      Mailbox::DraftMessage,
      id: 2,
      errors: {},
      variables: {
        email: "test2@email.com",
        full_name: "John Doe",
        income_tax_amount: "1000 zł",
        income_tax_type: "PIT-36",
        income_tax_period: "2021",
        income_tax_payment_deadline: "2021-05-31",
        value_added_tax_amount: "1000 zł",
        value_added_tax_type: "VAT-7",
        value_added_tax_period: "2021",
        value_added_tax_payment_deadline: "2021-05-31",
        account_number: "1234567890"
      }
    )
  end
  let(:draft_message3) do
    instance_double(
      Mailbox::DraftMessage,
      id: 3,
      index: 3,
      errors: { email: "Email is invalid", full_name: "Full name is invalid" },
      variables: {
        email: "test3@email.com",
        full_name: "John Doe"
      }
    )
  end
  let(:draft_message4) do
    instance_double(
      Mailbox::DraftMessage,
      id: 4,
      index: 4,
      errors: { email: "Email is invalid" },
      variables: {
        email: "test4@email.com",
        full_name: "John Doe"
      }
    )
  end

  describe "#valid_drafts" do
    subject(:valid_drafts) { presenter.valid_drafts }

    it "returns valid drafts" do
      expect(valid_drafts).to contain_exactly(
        an_instance_of(Mailbox::MessagesPackages::DraftPresenter::ValidMessage) & have_attributes(
          id: 1,
          email: "test1@email.com",
          full_name: "John Doe",
          income_tax_data: "1000 zł/PIT-36/2021/2021-05-31",
          value_added_tax_data: "-/-/-/-",
          account_number: "1234567890",
          preview: "mail body to render"
        ),
        an_instance_of(Mailbox::MessagesPackages::DraftPresenter::ValidMessage) & have_attributes(
          id: 2,
          email: "test2@email.com",
          full_name: "John Doe",
          income_tax_data: "1000 zł/PIT-36/2021/2021-05-31",
          value_added_tax_data: "1000 zł/VAT-7/2021/2021-05-31",
          account_number: "1234567890",
          preview: "mail body to render"
        )
      )
    end
  end

  describe "#invalid_drafts" do
    subject(:invalid_drafts) { presenter.invalid_drafts }

    it "returns invalid drafts" do
      expect(invalid_drafts).to contain_exactly(
        an_instance_of(Mailbox::MessagesPackages::DraftPresenter::InvalidMessage) & have_attributes(
          index: 3,
          email: "test3@email.com",
          full_name: "John Doe",
          errors: ["Email - Email is invalid", "Imię i nazwisko - Full name is invalid"]
        ),
        an_instance_of(Mailbox::MessagesPackages::DraftPresenter::InvalidMessage) & have_attributes(
          index: 4,
          email: "test4@email.com",
          full_name: "John Doe",
          errors: ["Email - Email is invalid"]
        )
      )
    end
  end
end
