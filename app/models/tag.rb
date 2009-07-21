# == Schema Information
# Schema version: 20090721144122
#
# Table name: tags
#
#  id             :integer(4)    not null, primary key
#  name           :string(255)   
#  badge          :boolean(1)    
#  blacklisted    :boolean(1)    
#  map_to_id      :integer(4)    
#  taggings_count :integer(4)    
#

class Tag < ActiveRecord::Base
  belongs_to :map_to, :class_name => 'Tag'
  has_many :taggings, :dependent => :destroy
  has_many :user_taggings, :through => :taggings
  has_many :podcasts, :through => :taggings

  validates_format_of     :name, :with => /^[a-z0-9]+$/
  validates_length_of     :name, :in => 1..32
  validates_uniqueness_of :name

  named_scope :badges, :conditions => {:badge => true}
  named_scope :without_badges, :conditions => "`tags`.`badge` IS NULL OR `tags`.`badge` = 0" # mysql, you scoundrel!

  # Search
  define_index do
    indexes :name, :badge
  end

  # Turns normal string into tag
  def self.tagize(str="")
    str.
      gsub("&", "and").
      gsub(/\s+/, "").
      gsub(/[^A-Za-z0-9]/, "").
      downcase
  end

  # Instance Methods
  def rating
    min    = Tag.minimum('taggings_count') || 0
    max    = Tag.maximum('taggings_count') || 1
    spread = max - min
    norm = ((taggings_count || 0) - min).abs

    rating = (norm.to_f / max * 10).ceil.to_s
  end

  def to_param
    name
  end

  def self.find_by_name!(name)
    self.find_by_name(name) or raise ActiveRecord::RecordNotFound
  end

end
