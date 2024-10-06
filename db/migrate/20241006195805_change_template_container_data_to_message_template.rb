class ChangeTemplateContainerDataToMessageTemplate < ActiveRecord::Migration[7.2]
  def change
    rename_table :template_data_containers, :message_templates
  end
end
