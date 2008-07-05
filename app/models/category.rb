class Category < ActiveRecord::Base
  has_many :podcasts

  def to_param
    "#{self.id}-#{self.name.gsub(/[^A-Za-z0-9]/, "-")}"
  end
end
