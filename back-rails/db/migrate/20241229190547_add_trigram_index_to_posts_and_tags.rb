class AddTrigramIndexToPostsAndTags < ActiveRecord::Migration[8.0]
  def change
    unless index_exists?(:posts, :title, using: :gin, opclass: :gin_trgm_ops)
      add_index :posts, :title, using: :gin, opclass: :gin_trgm_ops
    end

    unless index_exists?(:posts, :content, using: :gin, opclass: :gin_trgm_ops)
      add_index :posts, :content, using: :gin, opclass: :gin_trgm_ops
    end

    unless index_exists?(:tags, :name, using: :gin, opclass: :gin_trgm_ops)
      add_index :tags, :name, using: :gin, opclass: :gin_trgm_ops
    end
  end
end
