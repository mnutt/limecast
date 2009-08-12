# == Schema Information
# Schema version: 20090811161932
#
# Table name: authors
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)   
#  email      :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Author < ActiveRecord::Base
  before_validation :set_name_and_clean_url
  
  validates_presence_of :email
  validates_uniqueness_of :clean_url

  def user
    User.find_by_email(email.strip)
  end
  
  def podcasts
    Podcast.by(self)
  end

  def to_param
    clean_url
  end
  

  protected
  def set_name_and_clean_url
    self.name = email.dup.to_s if name.blank?
    self.name = name.split(/@/).first
    self.name = name.increment(" (%s)", 2) while Author.exists?(["name = ? AND id != ?", name, id.to_i])

    self.clean_url = (name.blank? ? 'author' : name.dup).to_s if clean_url.blank?
    self.clean_url = clean_url.gsub(/[^a-zA-Z0-9_]/, '_').gsub(/_+/, '_')
    self.clean_url = clean_url.increment("%s", 2) while Author.exists?(["clean_url = ? AND id != ?", clean_url, id.to_i])
  end
end
