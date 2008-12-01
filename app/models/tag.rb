# == Schema Information
# Schema version: 20081126170503
#
# Table name: tags
#
#  id          :integer(4)    not null, primary key
#  name        :string(255)
#  badge       :boolean(1)
#  blacklisted :boolean(1)
#  category    :boolean(1)
#  map_to_id   :integer(4)
#

class Tag < ActiveRecord::Base
  belongs_to :map_to, :class_name => 'Tag'
  has_many :taggings

  validates_format_of     :name, :with => /^[a-z0-9]+$/
  validates_length_of     :name, :in => 1..32
  validates_uniqueness_of :name
end
