class MessageTemplate < ApplicationRecord
  TEMPLATES = %w[taxes insurance].freeze

  TEMPLATES_CONFIGURATION = {
    taxes: MessageTemplate::Configuration.from_hash(
      rows: [
        [
          { label: :full_name, row_span: 2, variable: :full_name },
          { label: :email, row_span: 2, variable: :email }, # Template should require it
          { label: :pit, col_span: 4 },
          { label: :vat, col_span: 4 },
          { label: :account_number, variable: :account_number, row_span: 2 },
          { label: :dispatch_date, variable: :dispatch_date, row_span: 2 }, # Template should require it
          { label: :documents_provided_at, row_span: 2 },
          { label: :comment, row_span: 2 }
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
      ],
      data_start_row: 2
    )
  }

  validates :external_spreadsheet_id, uniqueness: true, presence: true
  validates :name, uniqueness: true, presence: true
  validates :template_name, presence: true, inclusion: { in: TEMPLATES }
  validates :url, presence: true

  has_many :messages_packages
end
