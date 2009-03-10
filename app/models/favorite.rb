# == Schema Information
<<<<<<< HEAD:app/models/favorite.rb
# Schema version: 20090303162109
=======
# Schema version: 20090306193031
>>>>>>> 1d54dce415fcb9ece7febfca4ef0e36fb671404b:app/models/favorite.rb
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
  belongs_to :podcast
end
