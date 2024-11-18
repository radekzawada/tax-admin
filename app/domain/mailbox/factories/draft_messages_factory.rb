class Mailbox::Factories::DraftMessagesFactory
  def self.default
    @default ||= new
  end

  def from_remote_data(remote_data, messages_package)
    message_template = messages_package.message_template
    variables = message_template.income_variables
    validations = message_template.validations

    remote_data.each_with_index.map do |row, index|
      row_data = assign_data_to_variables(row, variables)
      errors = validations.call(row_data).errors.to_h

      Mailbox::DraftMessage.new(
        index: index + message_template.data_start_row + 1,
        variables: row_data,
        errors:
      )
    end
  end

  private

  def assign_data_to_variables(row, variables)
    variables.to_h { |column_index, variable_name| [variable_name, row[column_index]] }
  end
end
