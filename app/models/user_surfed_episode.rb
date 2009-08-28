class UserSurfedEpisode < ActiveRecord::Base
  belongs_to :user
  belongs_to :episode
  
  validates_uniqueness_of :episode_id, :scope => :user_id
  
  def before_create
    self.viewed_at = Time.now
  end
end
