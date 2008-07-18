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
                                 :small  => ["170x170#", :png] }
  has_many :comments, :as => :commentable, :dependent => :destroy

  before_create :generate_clean_title

  def generate_clean_title
    self.clean_title = self.published_at.strftime('%Y-%b-%d-%H-%M')
  end

  def to_param
    clean_title
  end
end
