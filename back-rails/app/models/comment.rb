class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :content, presence: { message: "não pode estar vazio" }

  def author_name
    user ? user.full_name : "Anônimo"
  end
end
