# == Schema Information
# Schema version: 20090303162109
#
# Table name: user_taggings
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)    
#  tagging_id :integer(4)    
#

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
