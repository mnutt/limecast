# == Schema Information
# Schema version: 20090811161932
#
# Table name: favorites
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)    
#  podcast_id :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :podcast, :counter_cache => true

  validates_uniqueness_of :user_id, :scope => :podcast_id, :allow_nil => true

  def claim_by(user)
    self.user = user
    save
  end
end
