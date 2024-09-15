class AddNameToTemplateDataContainer < ActiveRecord::Migration[7.2]
  def change
    add_column :template_data_containers, :name, :string, null: false
    add_index :template_data_containers, :name, unique: true
  end
end
