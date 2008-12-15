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

  def download_logo(link)
    file = PaperClipFile.new
    file.original_filename = File.basename(link)

    open(link) do |f|
      return unless f.content_type =~ /^image/

      file.content_type = f.content_type
      file.to_tempfile = with(Tempfile.new('logo')) do |tmp|
        tmp.write(f.read)
        tmp.rewind
        tmp
      end
    end

    self.attachment_for(:screenshot).assign(file)
  end
  def file_name
    File.basename(self.url)
  end

  def primary?
    feed.primary?
  end
end
