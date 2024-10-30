class CreateMessagesTable < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :messages_package_dispatch, null: false, foreign_key: true

      t.string :recipient_email, null: false
      t.text :preview, null: false
      t.jsonb :variables, null: false

      t.datetime :sent_at
      t.timestamps
    end
  end
end
