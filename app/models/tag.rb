class Tag < ActiveRecord::Base
  belongs_to :map_to, :class_name => 'Tag'
  has_many :taggings

  validates_format_of     :name, :with => /^[a-z0-9]+$/
  validates_length_of     :name, :in => 1..32
  validates_uniqueness_of :name
end
