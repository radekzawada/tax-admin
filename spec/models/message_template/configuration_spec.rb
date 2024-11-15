require "rails_helper"

RSpec.describe MessageTemplate::Configuration, type: :model do
  describe ".from_hash" do
    subject(:from_hash) { described_class.from_hash(rows:, data_start_row:, validations:) }

    let(:rows) do
      [
        [
          { label: :full_name, row_span: 2, variable: :full_name },
          { label: :email, row_span: 2, variable: :email },
          { label: :pit, col_span: 4 },
          { label: :vat, col_span: 4 },
          { label: :account_number, variable: :account_number, row_span: 2 }
        ],
        [
          { gap: true },
          { gap: true },
          { label: :tax_type, variable: :income_tax_type, type: :enum, options: %w[PIT-36L PIT-36 PIT-28] },
          { label: :period, variable: :income_period },
          { label: :payment_deadline, variable: :income_payment_deadline },
          { label: :tax_amount, variable: :income_tax_amount },

          { label: :tax_type, variable: :value_added_tax_type, type: :enum, options: %w[VAT-7 VAT-7K] },
          { label: :period, variable: :value_added_period },
          { label: :payment_deadline, variable: :value_added_payment_deadline },
          { label: :tax_amount, variable: :value_added_tax_amount }
        ]
      ]
    end
    let(:data_start_row) { 2 }
    let(:validations) { Proc.new { } }

    it "creates a new Configuration instance from a hash" do
      expect(from_hash).to be_a(described_class) && have_attributes(
        rows: contain_exactly(
          include(
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :full_name, col_span: 1, row_span: 2, variable: { name: :full_name, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :email, col_span: 1, row_span: 2, variable: { name: :email, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :pit, col_span: 4
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :vat, col_span: 4
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :account_number, col_span: 1, row_span: 2, variable: { name: :account_number, type: :income }
            )
          ),
          include(
            an_instance_of(MessageTemplate::Configuration::Gap) & have_attributes(
              displayable: false, col_span: 1, row_span: 1
            ),
            an_instance_of(MessageTemplate::Configuration::Gap) & have_attributes(
              displayable: false, col_span: 1, row_span: 1
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :tax_type, variable: { name: :income_tax_type, type: :income }, type: :enum,
              options: %w[PIT-36L PIT-36 PIT-28]
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :period, variable: { name: :income_period, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :payment_deadline, variable: { name: :income_payment_deadline, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :tax_amount, variable: { name: :income_tax_amount, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :tax_type, variable: { name: :value_added_tax_type, type: :income },
              type: :enum, options: %w[VAT-7 VAT-7K]
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :period, variable: { name: :value_added_period, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :payment_deadline, variable: { name: :value_added_payment_deadline, type: :income }
            ),
            an_instance_of(MessageTemplate::Configuration::Header) & have_attributes(
              label: :tax_amount, variable: { name: :value_added_tax_amount, type: :income }
            )
          )
        ),
        data_start_row: 2,
        validations:
      )
    end
  end
end
