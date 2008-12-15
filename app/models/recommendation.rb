class Recommendation < ActiveRecord::Base
  belongs_to :podcast
  belongs_to :related_podcast, :class_name => 'Podcast'
end
