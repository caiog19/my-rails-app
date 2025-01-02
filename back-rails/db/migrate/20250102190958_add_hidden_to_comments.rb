class AddHiddenToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :hidden, :boolean, default: false, null: false
  end
end
