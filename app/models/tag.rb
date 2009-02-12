# == Schema Information
# Schema version: 20090201232032
#
# Table name: tags
#
#  id          :integer(4)    not null, primary key
#  name        :string(255)   
#  badge       :boolean(1)    
#  blacklisted :boolean(1)    
#  map_to_id   :integer(4)    
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

  # Search
  define_index do
    indexes :name, :badge
  end

  # Instance Methods
  def rating
    min    = Tag.minimum('taggings_count') || 0
    max    = Tag.maximum('taggings_count') || 1
    spread = max - min
    norm = ((taggings_count || 0) - min).abs 
    
    rating = case ((norm.to_f / max) * 100).to_i
               when 0..10  then "1"
               when 11..20 then "2"
               when 21..30 then "3"
               when 31..40 then "4"
               when 41..50 then "5"
               when 51..60 then "6"
               when 61..70 then "7"
               when 71..80 then "8"
               when 81..90 then "9"
               when 91..100 then "10"
             end
    
#    Max 11
#    Min 3
#    Spread 8
  end

  def to_param
    name
  end

end
