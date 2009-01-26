# This is merely a denormalized table to track which users added taggings.
class UserTagging < ActiveRecord::Base
  belongs_to :user
  belongs_to :tagging
  
  validates_uniqueness_of :tagging_id, :scope => :user_id
  
  def podcast
    tagging.podcast
  end
  
  def tag
    tagging.tag
  end
end