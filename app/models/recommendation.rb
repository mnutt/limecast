# == Schema Information
# Schema version: 20090811161932
#
# Table name: recommendations
#
#  id                 :integer(4)    not null, primary key
#  podcast_id         :integer(4)    
#  related_podcast_id :integer(4)    
#  weight             :integer(4)    
#  created_at         :datetime      
#  updated_at         :datetime      
#

class Recommendation < ActiveRecord::Base
  belongs_to :podcast
  belongs_to :related_podcast, :class_name => 'Podcast'

  named_scope :by_weight,   :order => "weight DESC"
  named_scope :for_podcast, lambda {|p| {:conditions => {:podcast_id => p}} }
end
