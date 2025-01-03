class AddVotesToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :upvotes, :integer, default: 0, null: false
    add_column :comments, :downvotes, :integer, default: 0, null: false
  end
end
