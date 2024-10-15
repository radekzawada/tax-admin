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
  end

  class Gap < Cell
    attribute :displayable, Types::Bool.default(false)
  end

  class Header < Cell
    attribute :label, Types::Symbol
    attribute :variable?, Types::Symbol
    attribute :type, Types::Symbol.default(:string)
    attribute :options?, Types::Array.of(Types::String)

    def validatable?
      type == :enum
    end
  end

  attribute :rows, Types::Array.of(Types::Array.of(Types::Instance(Header) | Types::Instance(Gap)))
  attribute :data_start_row, Types::Integer

  def self.from_hash(rows:, **data)
    new(
      rows: rows.map do |row|
        row.map { |cell| cell.delete(:gap) ? Gap.new(cell) : Header.new(cell) }
      end,
      **data
    )
  end

  def columns_count
    rows.map { |row| row.sum(&:col_span) }.max
  end
end
