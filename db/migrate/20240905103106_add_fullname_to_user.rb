class AddFullnameToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :fullname, :string, null: false
  end
end
