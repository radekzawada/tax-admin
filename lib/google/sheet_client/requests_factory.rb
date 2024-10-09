class Google::SheetClient::RequestsFactory
  RequestsContainer = Struct.new(:merged_cells, :cells_data) do
    def initialize
      super([], [])
    end
  end

  def build_requests_from_template_configuration(sheet, configuration)
    container = RequestsContainer.new
    requests = []
    header_data = []

    configuration.columns.each_with_index do |columns, row_index|
      column_index = 0
      columns.each do |column_config|
        if column_config.col_span > 1 || column_config.row_span > 1
          requests << build_merge_cells_request(sheet, row_index, column_index, column_config)
        end

        column_index += column_config.col_span
      end
      header_data << build_row_data_for_header(sheet, columns)
    end

    requests << Google::Apis::SheetsV4::Request.new(
      update_cells: Google::Apis::SheetsV4::UpdateCellsRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet.properties.sheet_id,
          start_row_index: 0,
          end_row_index: configuration.columns.size,
          start_column_index: 0,
          end_column_index: configuration.columns.map(&:size).max
        ),
        rows: header_data,
        fields: "userEnteredFormat(horizontalAlignment,backgroundColor,textFormat),userEnteredValue",
        include_merging: true
      )
    )

    requests
  end

  private

  def build_merge_cells_request(sheet, row_index, column_index, column_config)
    Google::Apis::SheetsV4::Request.new(
      merge_cells: Google::Apis::SheetsV4::MergeCellsRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet.properties.sheet_id,
          start_row_index: row_index,
          end_row_index: row_index + column_config.row_span,
          start_column_index: column_index,
          end_column_index: column_index + column_config.col_span
        ),
        merge_type: "MERGE_ALL"
      )
    )
  end

  def build_row_data_for_header(sheet, columns)
    Google::Apis::SheetsV4::RowData.new(
      values: columns.map do |column_config|
        value_cell = Google::Apis::SheetsV4::CellData.new(
          user_entered_format: Google::Apis::SheetsV4::CellFormat.new(
            horizontal_alignment: "CENTER",
            text_format: Google::Apis::SheetsV4::TextFormat.new(bold: true)
          ),
          user_entered_value: Google::Apis::SheetsV4::ExtendedValue.new(
            string_value: column_label(column_config)
          )
        )

        gaps = (column_config.col_span - 1).times.map do
          Google::Apis::SheetsV4::CellData.new(
            user_entered_value: Google::Apis::SheetsV4::ExtendedValue.new(
              string_value: nil
            )
          )
        end

        [ value_cell, *gaps ]
      end.flatten
    )
  end

  def column_label(column_config)
    return unless column_config.displayable

    I18n.t("sheet.headers.#{column_config.label}")
  end
end
