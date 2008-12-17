# == Schema Information
# Schema version: 20081126170503
#
# Table name: sources
#
#  id         :integer(4)    not null, primary key
#  url        :string(255)
#  type       :string(255)
#  guid       :string(255)
#  size       :integer(4)
#  episode_id :integer(4)
#  format     :string(255)
#  feed_id    :integer(4)
#

class Source < ActiveRecord::Base
  belongs_to :feed
  belongs_to :episode

  has_attached_file :screenshot
  has_attached_file :preview

  def file_name
    File.basename(self.url)
  end

  def primary?
    feed.primary?
  end
end
