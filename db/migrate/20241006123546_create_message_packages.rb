class CreateMessagePackages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages_packages do |t|
      t.string :name, null: false
      t.references :message_template, null: false, foreign_key: { to_table: :template_data_containers }
      t.string :status, null: false

      t.timestamps
    end
  end
end
