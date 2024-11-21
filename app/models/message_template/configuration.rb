# TODO: Add more complex validation for configuration
class MessageTemplate::Configuration < Dry::Struct
  COLUMN_TYPES = %i[string enum].freeze

  class Cell < Dry::Struct
    attribute :col_span, Types::Integer.default(1)
    attribute :row_span, Types::Integer.default(1)
    attribute :displayable, Types::Bool.default(true)

    def merge_cells?
      col_span > 1 || row_span > 1
    end

    def validatable?
      false
    end

    def income_variable?
      false
    end
  end

  class Gap < Cell
    attribute :displayable, Types::Bool.default(false)
  end

  class Header < Cell
    attribute :label, Types::Symbol
    attribute :variable?, Types::Coercible::TemplateVariable
    attribute :type, Types::Symbol.default(:string)
    attribute :options?, Types::Array.of(Types::String)

    def validatable?
      type == :enum
    end

    def income_variable?
      variable.to_h[:type] == :income
    end
  end

  attribute :rows, Types::Array.of(Types::Array.of(Types::Instance(Header) | Types::Instance(Gap)))
  attribute :data_start_row, Types::Integer
  attribute :validations, Types::Interface(:call)
  attribute :mailer_message, Types::Symbol

  def self.from_hash(rows:, **data)
    new(
      rows: rows.map do |row|
        row.map { |cell| cell.delete(:gap) ? Gap.new(cell) : Header.new(cell) }
      end,
      **data
    )
  end

  def columns_count
    @columns_count ||= rows.map { |row| row.sum(&:col_span) }.max
  end

  def income_variables
    @income_variables ||= rows.each_with_object({}).with_index do |(row, result), row_index|
      col_index = 0

      row.each do |config|
        if config.income_variable?
          variable_name = config.variable[:name]
          result[col_index] = variable_name
        end
        col_index += config.col_span
      end
    end.compact.sort.to_h
  end
end
