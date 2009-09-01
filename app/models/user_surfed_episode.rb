class UserSurfedEpisode < ActiveRecord::Base
  belongs_to :user
  belongs_to :episode
  
  validates_uniqueness_of :user_id, :scope => :episode_id, :allow_nil => true
  
  def before_create
    self.viewed_at = Time.now
  end
  
  def claim_by(user)
    self.user = user
    save
  end
end
