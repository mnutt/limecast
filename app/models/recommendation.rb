# == Schema Information
<<<<<<< HEAD:app/models/recommendation.rb
# Schema version: 20090303162109
=======
# Schema version: 20090306193031
>>>>>>> 1d54dce415fcb9ece7febfca4ef0e36fb671404b:app/models/recommendation.rb
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
