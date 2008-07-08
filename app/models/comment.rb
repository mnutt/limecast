# == Schema Information
# Schema version: 20080701214920
#
# Table name: comments
#
#  id               :integer       not null, primary key
#  user_id          :integer       
#  commentable_type :string(255)   
#  commentable_id   :integer       
#  body             :text          
#  created_at       :datetime      
#  updated_at       :datetime      
#  title            :string(255)   
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :commenter, :class_name => 'User', :foreign_key => 'user_id'
end
