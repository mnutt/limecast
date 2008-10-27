class Tag < ActiveRecord::Base
  belongs_to :map_to, :class_name => 'Tag'

  has_many :taggings
end
