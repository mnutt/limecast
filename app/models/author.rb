class Author < ActiveRecord::Base
  before_save :set_name

  def user
    User.find_by_email(email.strip)
  end
  
  def podcasts
    Podcast.by(self)
  end

  def to_param
    name
  end
  

  protected
  def set_name
    if !email.blank? && (name.blank? || name_changed?)
      self.name = email.split(/@/).first
      self.name.gsub!(/[^a-zA-Z0-9]/, '_')
      self.name.increment!("_%s", 2) while Author.exists?(["name = ? AND id != ?", name, id.to_i])
    end
  end
end