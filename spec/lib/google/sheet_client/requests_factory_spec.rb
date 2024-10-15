require "rails_helper"

RSpec.describe Google::SheetClient::RequestsFactory do
  describe "#from_template_configuration" do
    subject(:from_template_configuration) { described_class.new.from_template_configuration(sheet, configuration) }

    let(:sheet) { instance_double(Google::Apis::SheetsV4::Sheet, properties:) }
    let(:properties) { instance_double(Google::Apis::SheetsV4::SheetProperties, sheet_id: 1, grid_properties:) }
    let(:grid_properties) { instance_double(Google::Apis::SheetsV4::GridProperties, row_count: 11) }
    let(:configuration) { MessageTemplate::TEMPLATES_CONFIGURATION[:taxes] }
    let(:empty_cell) do
      an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
        user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(string_value: nil)
      )
    end
    let(:merged_cells_config) do
      [
        { start_row_index: 0, end_row_index: 2, start_column_index: 0, end_column_index: 1, sheet_id: 1 },
        { start_row_index: 0, end_row_index: 2, start_column_index: 1, end_column_index: 2, sheet_id: 1 },
        { start_row_index: 0, end_row_index: 1, start_column_index: 2, end_column_index: 6, sheet_id: 1 },
        { start_row_index: 0, end_row_index: 1, start_column_index: 6, end_column_index: 10, sheet_id: 1 },
        { start_row_index: 0, end_row_index: 2, start_column_index: 10, end_column_index: 11, sheet_id: 1 },
        { start_row_index: 0, end_row_index: 2, start_column_index: 11, end_column_index: 12, sheet_id: 1 }
      ]
    end

    it "builds requests that configure the sheet" do
      # binding.pry
      expect(from_template_configuration).to include(
        *merged_cells_config.map do |config|
          an_instance_of(Google::Apis::SheetsV4::Request) & have_attributes(
            merge_cells: an_instance_of(Google::Apis::SheetsV4::MergeCellsRequest) & have_attributes(
              merge_type: "MERGE_ALL",
              range: an_instance_of(Google::Apis::SheetsV4::GridRange) & have_attributes(**config)
            )
          )
        end,
        an_instance_of(Google::Apis::SheetsV4::Request) & have_attributes(
          update_cells: an_instance_of(Google::Apis::SheetsV4::UpdateCellsRequest) & have_attributes(
            fields: "userEnteredFormat(horizontalAlignment,backgroundColor,textFormat),userEnteredValue",
            range: an_instance_of(Google::Apis::SheetsV4::GridRange) & have_attributes(
              start_row_index: 0, end_row_index: 2, start_column_index: 0, end_column_index: 12, sheet_id: 1
            ),
            rows: contain_exactly(
              an_instance_of(Google::Apis::SheetsV4::RowData) & have_attributes(
                values: contain_exactly(
                  *[ "Imię i nazwisko", "Email", "PIT" ].map do |value|
                    an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
                      user_entered_format: an_instance_of(Google::Apis::SheetsV4::CellFormat) & have_attributes(
                        horizontal_alignment: "CENTER",
                        text_format: an_instance_of(Google::Apis::SheetsV4::TextFormat) & have_attributes(bold: true)
                      ),
                      user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(string_value: value)
                    )
                  end,
                  *3.times.map { empty_cell },
                  an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
                    user_entered_format: an_instance_of(Google::Apis::SheetsV4::CellFormat) & have_attributes(
                      horizontal_alignment: "CENTER",
                      text_format: an_instance_of(Google::Apis::SheetsV4::TextFormat) & have_attributes(bold: true)
                    ),
                    user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(
                      string_value: "VAT"
                    )
                  ),
                  *3.times.map { empty_cell },
                  an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
                    user_entered_format: an_instance_of(Google::Apis::SheetsV4::CellFormat) & have_attributes(
                      horizontal_alignment: "CENTER",
                      text_format: an_instance_of(Google::Apis::SheetsV4::TextFormat) & have_attributes(bold: true)
                    ),
                    user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(
                      string_value: "Numer konta"
                    )
                  ),
                  an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
                    user_entered_format: an_instance_of(Google::Apis::SheetsV4::CellFormat) & have_attributes(
                      horizontal_alignment: "CENTER",
                      text_format: an_instance_of(Google::Apis::SheetsV4::TextFormat) & have_attributes(bold: true)
                    ),
                    user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(
                      string_value: "Data wysyłki"
                    )
                  )
                )
              ),
              an_instance_of(Google::Apis::SheetsV4::RowData) & have_attributes(
                values: contain_exactly(
                  *2.times.map { empty_cell },
                  *[
                    "Rodzaj podatku", "Okres", "Termin płatności", "Kwota podatku",
                    "Rodzaj podatku", "Okres", "Termin płatności", "Kwota podatku"
                  ].map do |value|
                    an_instance_of(Google::Apis::SheetsV4::CellData) & have_attributes(
                      user_entered_format: an_instance_of(Google::Apis::SheetsV4::CellFormat) & have_attributes(
                        horizontal_alignment: "CENTER",
                        text_format: an_instance_of(Google::Apis::SheetsV4::TextFormat) & have_attributes(bold: true)
                      ),
                      user_entered_value: an_instance_of(Google::Apis::SheetsV4::ExtendedValue) & have_attributes(
                        string_value: value
                      )
                    )
                  end
                )
              )
            )
          )
        ),
        an_instance_of(Google::Apis::SheetsV4::Request) & have_attributes(
          set_data_validation: an_instance_of(Google::Apis::SheetsV4::SetDataValidationRequest) & have_attributes(
            range: an_instance_of(Google::Apis::SheetsV4::GridRange) & have_attributes(
              start_row_index: 2, end_row_index: 11, start_column_index: 2, end_column_index: 3, sheet_id: 1
            ),
            rule: an_instance_of(Google::Apis::SheetsV4::DataValidationRule) & have_attributes(
              condition: an_instance_of(Google::Apis::SheetsV4::BooleanCondition) & have_attributes(
                type: "ONE_OF_LIST",
                values: contain_exactly(
                  an_instance_of(Google::Apis::SheetsV4::ConditionValue) & have_attributes(user_entered_value: "PIT-36L"),
                  an_instance_of(Google::Apis::SheetsV4::ConditionValue) & have_attributes(user_entered_value: "PIT-36"),
                  an_instance_of(Google::Apis::SheetsV4::ConditionValue) & have_attributes(user_entered_value: "PIT-28")
                )
              ),
              strict: true,
              show_custom_ui: true
            )
          )
        ),
        an_instance_of(Google::Apis::SheetsV4::Request) & have_attributes(
          set_data_validation: an_instance_of(Google::Apis::SheetsV4::SetDataValidationRequest) & have_attributes(
            range: an_instance_of(Google::Apis::SheetsV4::GridRange) & have_attributes(
              start_row_index: 2, end_row_index: 11, start_column_index: 6, end_column_index: 7, sheet_id: 1
            ),
            rule: an_instance_of(Google::Apis::SheetsV4::DataValidationRule) & have_attributes(
              condition: an_instance_of(Google::Apis::SheetsV4::BooleanCondition) & have_attributes(
                type: "ONE_OF_LIST",
                values: contain_exactly(
                  an_instance_of(Google::Apis::SheetsV4::ConditionValue) & have_attributes(user_entered_value: "VAT-7"),
                  an_instance_of(Google::Apis::SheetsV4::ConditionValue) & have_attributes(user_entered_value: "VAT-7K")
                )
              ),
              strict: true,
              show_custom_ui: true
            )
          )
        )
      )
    end
  end
end
