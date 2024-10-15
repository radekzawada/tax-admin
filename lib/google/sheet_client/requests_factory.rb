class Google::SheetClient::RequestsFactory
  RequestsContainer = Struct.new(:merge_cells, :populate_cells, :data_validations) do
    def initialize
      super([], [], [])
    end

    def all_requests
      [*merge_cells, *populate_cells, *data_validations]
    end
  end

  def from_template_configuration(sheet, configuration)
    container = RequestsContainer.new

    container.merge_cells += build_merge_cells_requests(sheet, configuration)
    container.populate_cells << build_populate_headers_request(sheet, configuration)
    container.data_validations += build_data_validation_requests(sheet, configuration)

    container.all_requests
  end

  private

  def build_merge_cells_requests(sheet, configuration)
    configuration.rows.each_with_index.flat_map do |cells, row_index|
      column_index = 0
      merge_requests = cells.map do |cell_config|
        (build_merge_cells_request(sheet, row_index, column_index, cell_config) if cell_config.merge_cells?).tap do
          column_index += cell_config.col_span
        end
      end

      merge_requests.compact
    end
  end

  def build_merge_cells_request(sheet, row_index, column_index, cell_config)
    Google::Apis::SheetsV4::Request.new(
      merge_cells: Google::Apis::SheetsV4::MergeCellsRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet.properties.sheet_id,
          start_row_index: row_index,
          end_row_index: row_index + cell_config.row_span,
          start_column_index: column_index,
          end_column_index: column_index + cell_config.col_span
        ),
        merge_type: Google::SheetClient::MERGE_ALL_TYPE
      )
    )
  end

  def build_populate_headers_request(sheet, configuration)
    Google::Apis::SheetsV4::Request.new(
      update_cells: Google::Apis::SheetsV4::UpdateCellsRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet.properties.sheet_id,
          start_row_index: 0,
          end_row_index: configuration.rows.size,
          start_column_index: 0,
          end_column_index: configuration.columns_count
        ),
        rows: configuration.rows.map { |row| build_row_data_for_header(sheet, row) },
        fields: Google::SheetClient::UPDATE_FORMAT_AND_VALUE_FIELDS,
        include_merging: true
      )
    )
  end

  def build_data_validation_requests(sheet, configuration)
    column_index = 0
    configuration.rows.last.map do |cell_config|
      if cell_config.validatable?
        build_data_validation_request(sheet, configuration, cell_config, column_index)
      end.tap { column_index += cell_config.col_span }
    end.compact
  end

  def build_data_validation_request(sheet, configuration, cell_config, column_index)
    Google::Apis::SheetsV4::Request.new(
      set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
        range: Google::Apis::SheetsV4::GridRange.new(
          sheet_id: sheet.properties.sheet_id,
          start_row_index: configuration.data_start_row,
          end_row_index: sheet.properties.grid_properties.row_count,
          start_column_index: column_index,
          end_column_index: column_index + cell_config.col_span
        ),
        rule: Google::Apis::SheetsV4::DataValidationRule.new(
          condition: Google::Apis::SheetsV4::BooleanCondition.new(
            type: "ONE_OF_LIST",
            values: cell_config.options.map do |option|
              Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: option)
            end
          ),
          strict: true,
          show_custom_ui: true
        )
      )
    )
  end

  def build_row_data_for_header(sheet, cells)
    Google::Apis::SheetsV4::RowData.new(
      values: cells.map do |config|
        value_cell = Google::Apis::SheetsV4::CellData.new(
          user_entered_format: Google::SheetClient::HEADER_CELL_FORMAT,
          user_entered_value: Google::Apis::SheetsV4::ExtendedValue.new(
            string_value: column_label(config)
          )
        )

        gaps = Array.new(config.col_span - 1) { Google::SheetClient::GAP }

        [value_cell, *gaps]
      end.flatten
    )
  end

  def column_label(cell_config)
    return unless cell_config.displayable

    I18n.t("sheet.headers.#{cell_config.label}")
  end
end
