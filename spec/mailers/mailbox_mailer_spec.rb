require "rails_helper"

RSpec.describe MailboxMailer, type: :mailer do
  describe "tax_information_message" do
    subject(:mail) { described_class.tax_information_message(draft_message) }

    let(:draft_message) { instance_double(Mailbox::DraftMessage, variables:) }
    let(:variables) do
      {
        email: "test@mail.com",
        income_tax_type: "PIT-36",
        income_tax_period: "2021",
        income_tax_payment_deadline: "2021-05-31",
        income_tax_amount: "1000 zł",
        account_number: "1234567890"
      }
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Informacje podatkowe")
      expect(mail.to).to eq(["test@mail.com"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("PIT-36")
    end
  end

  describe "insurance_information_message" do
    subject(:mail) { described_class.insurance_information_message(draft_message) }

    let(:draft_message) { instance_double(Mailbox::DraftMessage, variables:) }
    let(:variables) do
      {
        email: "test@mail.com",
        full_name: "John Doe",
        period: "2021",
        payment_deadline: "2021-05-31",
        amount: "1000 zł",
        account_number: "1234567890"
      }
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Składka ubezpieczeniowa")
      expect(mail.to).to eq(["test@mail.com"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("1234567890")
    end
  end
end
