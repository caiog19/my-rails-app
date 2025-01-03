class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :vote_type, inclusion: { in: %w[upvote downvote] }
  validates :user_id, uniqueness: { scope: :comment_id, message: "Você já votou neste comentário" }

  after_create :increment_vote_count
  after_destroy :decrement_vote_count
  after_update :update_vote_count, if: :saved_change_to_vote_type?

  private

  def increment_vote_count
    if vote_type == 'upvote'
      comment.increment!(:upvotes)
    else
      comment.increment!(:downvotes)
    end
  end

  def decrement_vote_count
    if vote_type == 'upvote'
      comment.decrement!(:upvotes)
    else
      comment.decrement!(:downvotes)
    end
  end

  def update_vote_count
    previous_type, current_type = saved_change_to_vote_type_
    if previous_type == 'upvote' && current_type == 'downvote'
      comment.decrement!(:upvotes)
      comment.increment!(:downvotes)
    elsif previous_type == 'downvote' && current_type == 'upvote'
      comment.decrement!(:downvotes)
      comment.increment!(:upvotes)
    end
  end
end
