class AddUrlToDataTemplate < ActiveRecord::Migration[7.2]
  def change
    add_column :template_data_containers, :url, :string
  end
end
