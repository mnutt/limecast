class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :episode


  def podcast
    episode.podcast
  end
end
