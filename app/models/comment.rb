# == Schema Information
# Schema version: 20080922184801
#
# Table name: comments
#
#  id             :integer(4)    not null, primary key
#  user_id        :integer(4)    
#  body           :text          
#  created_at     :datetime      
#  updated_at     :datetime      
#  title          :string(255)   
#  positive       :boolean(1)    
#  episode_id     :integer(4)    
#  insightful     :integer(4)    default(0)
#  not_insightful :integer(4)    default(0)
#

class Comment < ActiveRecord::Base
  belongs_to :episode
  belongs_to :commenter, :class_name => 'User', :foreign_key => 'user_id'

  after_create :distribute_point

  named_scope :newer_than, lambda {|who| {:conditions => ["comments.created_at >= (?)", who.created_at]} }
  named_scope :without, lambda {|who| {:conditions => ["comments.id NOT IN (?)", who.id]} }
  named_scope :for_podcast, lambda {|podcast| {:conditions => {:episode_id => podcast.episodes.map(&:id)}} }
  named_scope :that_are_positive, :conditions => {:positive => true}
  named_scope :that_are_negative, :conditions => {:positive => false}

  def editable?
    self.episode.open_for_comments?
  end

  protected

  def distribute_point
    self.commenter.score += 1
    self.commenter.save
  end

end
