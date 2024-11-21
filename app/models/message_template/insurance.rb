class MessageTemplate::Insurance
  DataSchema = Dry::Validation.Contract do
    params do
      required(:full_name).filled(:string)
      required(:email).filled(Types::Email)
      required(:account_number).filled(:string)

      required(:period).filled(:string)
      required(:payment_deadline).filled(:string)
      required(:amount).filled(:string)
    end
  end

  CONFIGURATION = MessageTemplate::Configuration.from_hash(
    rows: [
      [
        { label: :full_name, variable: :full_name },
        { label: :email, variable: :email },
        { label: :period, variable: :period },
        { label: :payment_deadline, variable: :payment_deadline },
        { label: :amount, variable: :amount },
        { label: :account_number, variable: :account_number },
        { label: :dispatch_date, variable: %i[dispatch_date outcome] },
        { label: :comment }
      ]
    ],
    data_start_row: 1,
    validations: DataSchema,
    mailer_message: :insurance_information_message
  )
end
