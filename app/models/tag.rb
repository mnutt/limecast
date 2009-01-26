# == Schema Information
# Schema version: 20090123214455
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
  def to_param
    name
  end


end
