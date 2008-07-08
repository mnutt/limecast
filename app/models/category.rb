# == Schema Information
# Schema version: 20080701214920
#
# Table name: categories
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  position   :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class Category < ActiveRecord::Base
  has_many :podcasts

  def to_param
    "#{self.id}-#{self.name.gsub(/[^A-Za-z0-9]/, "-")}"
  end
end
