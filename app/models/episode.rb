class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail,
                    :styles => { :square => ["64x64#", :png],
                                 :small  => "150x150>" }
end
