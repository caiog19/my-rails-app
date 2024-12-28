class CreateJoinTablePostsTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :posts, :tags do |t|
      t.index [:post_id, :tag_id], unique: true
      t.index [:tag_id, :post_id], unique: true
    end
  end
end
