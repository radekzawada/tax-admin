class IntroducePackageDispatch < ActiveRecord::Migration[7.2]
  def change
    create_table :messages_package_dispatches do |t|
      t.references :messages_package, null: false, foreign_key: true
      t.string :status, null: false

      t.datetime :data_loaded_at
      t.references :data_loaded_by, foreign_key: { to_table: :users }

      t.datetime :dispatched_at
      t.references :dispatched_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
