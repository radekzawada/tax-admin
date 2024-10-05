class MakeUrlRequiredForDataTemplate < ActiveRecord::Migration[7.2]
  def change
    change_column_null :template_data_containers, :url, false
  end
end
