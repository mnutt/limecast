# == Schema Information
# Schema version: 20080829144522
#
# Table name: comments
#
#  id               :integer(4)    not null, primary key
#  user_id          :integer(4)    
#  commentable_type :string(255)   
#  commentable_id   :integer(4)    
#  body             :text          
#  created_at       :datetime      
#  updated_at       :datetime      
#  title            :string(255)   
#  positive         :boolean(1)    
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :commenter, :class_name => 'User', :foreign_key => 'user_id'

  after_create :distribute_point

  named_scope :newer_than, lambda {|who| {:conditions => ["comments.created_at >= (?)", who.created_at]} }
  named_scope :without, lambda {|who| {:conditions => ["comments.id NOT IN (?)", who.id]} }

  def editable?
    self.commentable.
      comments.
      newer_than(self).
      without(self).
      count < 1
  end

  protected

  def distribute_point
    self.commenter.score += 1
    self.commenter.save
  end

end
