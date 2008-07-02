class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail, :whiny_thumbnails => true,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["150x150#", :png] }
  has_many :comments, :as => :commentable, :dependent => :destroy

  def to_param
    "#{self.id}-#{self.title.gsub(/[^A-Za-z0-9]/, "")}"
  end
end
