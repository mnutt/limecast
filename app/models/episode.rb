class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail, :whiny_thumbnails => true,
                    :styles => { :square => ["64x64#", :png],
                                 :small  => ["150x150>", :png] }
  has_many :comments, :as => :commentable, :dependent => :destroy
end
