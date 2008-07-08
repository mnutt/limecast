# == Schema Information
# Schema version: 20080701214920
#
# Table name: episodes
#
#  id                     :integer       not null, primary key
#  podcast_id             :integer       
#  summary                :text          
#  enclosure_url          :string(255)   
#  published_at           :datetime      
#  created_at             :datetime      
#  updated_at             :datetime      
#  thumbnail_file_size    :integer       
#  thumbnail_file_name    :string(255)   
#  thumbnail_content_type :string(255)   
#  guid                   :string(255)   
#  enclosure_type         :string(255)   
#  duration               :integer       
#  title                  :string(255)   
#

class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail, :whiny_thumbnails => true,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["150x150#", :png] }
  has_many :comments, :as => :commentable, :dependent => :destroy

  def to_param
    "#{self.id}-#{self.title.gsub(/[^A-Za-z0-9]/, "-")}"
  end
end
