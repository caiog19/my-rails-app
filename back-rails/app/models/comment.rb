class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  has_many :votes, dependent: :destroy
  
  validates :content, presence: { message: "não pode estar vazio" }

  def author_name
    user ? user.full_name : "Anônimo"
  end

  def toggle_hidden!
    update(hidden: !hidden)
  end

  def upvote!
    increment!(:upvotes)
  end

  def downvote!
    increment!(:downvotes)
  end
  
  def user_voted?(user, type)
    votes.exists?(user: user, vote_type: type)
  end

end
