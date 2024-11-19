class MessageTemplate::Taxes
  VAT_CONDITIONAL_FIELDS = %i[value_added_tax_period value_added_tax_payment_deadline value_added_tax_amount].freeze
  VAT_TYPES = %w[VAT-7 VAT-7K].freeze
  INCOME_TAX_TYPES = %w[PIT-36L PIT-36 PIT-28].freeze

  DataSchema = Dry::Validation.Contract do
    params do
      required(:full_name).filled(:string)
      required(:email).filled(Types::Email)
      required(:account_number).filled(:string)

      required(:income_tax_type).filled(:string, included_in?: INCOME_TAX_TYPES)
      required(:income_tax_period).filled(:string)
      required(:income_tax_payment_deadline).filled(:string)
      required(:income_tax_amount).filled(:string)

      optional(:value_added_tax_type).maybe(:string, included_in?: VAT_TYPES)
      optional(:value_added_tax_period).maybe(:string)
      optional(:value_added_tax_payment_deadline).maybe(:string)
      optional(:value_added_tax_amount).maybe(:string)
    end

    VAT_CONDITIONAL_FIELDS.each do |field|
      rule(field) do |income_tax_type|
        key.failure(:filled?) if value.blank? && values[:value_added_tax_type].present?
      end
    end
  end

  CONFIGURATION = MessageTemplate::Configuration.from_hash(
    rows: [
      [
        { label: :full_name, row_span: 2, variable: :full_name },
        { label: :email, row_span: 2, variable: :email }, # Template should require it
        { label: :pit, col_span: 4 },
        { label: :vat, col_span: 4 },
        { label: :account_number, variable: :account_number, row_span: 2 },
        { label: :dispatch_date, variable: %i[dispatch_date outcome], row_span: 2 }, # Template should require it
        { label: :documents_provided_at, row_span: 2 },
        { label: :comment, row_span: 2 }
      ],
      [
        { gap: true },
        { gap: true },
        { label: :tax_type, variable: :income_tax_type, type: :enum, options: %w[PIT-36L PIT-36 PIT-28] },
        { label: :period, variable: :income_tax_period },
        { label: :payment_deadline, variable: :income_tax_payment_deadline },
        { label: :tax_amount, variable: :income_tax_amount },

        { label: :tax_type, variable: :value_added_tax_type, type: :enum, options: %w[VAT-7 VAT-7K] },
        { label: :period, variable: :value_added_tax_period },
        { label: :payment_deadline, variable: :value_added_tax_payment_deadline },
        { label: :tax_amount, variable: :value_added_tax_amount }
      ]
    ],
    data_start_row: 2,
    validations: DataSchema
  )
end
