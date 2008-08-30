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
end
