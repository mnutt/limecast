# == Schema Information
# Schema version: 20080829144522
#
# Table name: episodes
#
#  id                     :integer(4)    not null, primary key
#  podcast_id             :integer(4)    
#  summary                :text          
#  enclosure_url          :string(255)   
#  published_at           :datetime      
#  created_at             :datetime      
#  updated_at             :datetime      
#  thumbnail_file_size    :integer(4)    
#  thumbnail_file_name    :string(255)   
#  thumbnail_content_type :string(255)   
#  guid                   :string(255)   
#  enclosure_type         :string(255)   
#  duration               :integer(4)    
#  title                  :string(255)   
#  clean_title            :string(255)   
#  enclosure_size         :integer(4)    
#

class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail, :whiny_thumbnails => true,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png] }
  has_many :comments, :as => :commentable, :dependent => :destroy

  validates_presence_of :podcast_id

  before_create :generate_url

  def generate_url
    self.clean_title = self.published_at.strftime('%Y-%b-%d')
    conflict = Episode.find(:first, :conditions => {:podcast_id => podcast.id, :clean_title => self.clean_title})
    self.clean_title += "-2" if conflict and conflict != self

    i = 2 # Number to attach to the end of the title to make it unique
    while(Episode.find(:first, :conditions => {:podcast_id => podcast.id, :clean_title => clean_title}) and conflict != self)
      i += 1
      self.clean_title.chop!
      self.clean_title += i.to_s
    end

    self.clean_title
  end

  def pretty_date
    self.published_at.to_formatted_s(:normal)
  end

  def to_param
    clean_title
  end

  def writable_by?(user)
    self.podcast.writable_by?(user)
  end

  def enclosure_magnet_url
    "magnet:?xs=#{enclosure_url}"
  end
end
