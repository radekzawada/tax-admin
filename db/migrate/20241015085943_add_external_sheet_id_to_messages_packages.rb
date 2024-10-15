class AddExternalSheetIdToMessagesPackages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages_packages, :external_sheet_id, :string
  end
end
