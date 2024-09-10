class CreateTemplateDataContainer < ActiveRecord::Migration[7.2]
  def change
    create_table :template_data_containers do |t|
      t.string :template_name, null: false
      t.string :external_spreadsheet_id, null: false
      t.string :permitted_emails, array: true, default: [], null: false

      t.timestamps

      t.index :external_spreadsheet_id, unique: true
    end
  end
end
