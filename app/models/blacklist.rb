# == Schema Information
# Schema version: 20090201232032
#
# Table name: blacklists
#
#  id         :integer(4)    not null, primary key
#  domain     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Blacklist < ActiveRecord::Base
end
