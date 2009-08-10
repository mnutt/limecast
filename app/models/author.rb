class Author < ActiveRecord::Base
  before_save :set_name

  def user
    User.find_by_email(email.strip)
  end

  protected
  def set_name
    if name.blank? || name_changed?
      self.name = email.blank? ? "author" : email.split(/@/).first
      self.name.gsub!(/[^a-zA-Z0-9]/, '_')
      self.name.increment!("_%s", 2) while Author.exists?(["name = ? AND id != ?", name, id.to_i])
    end
  end
end