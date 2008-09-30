class PodcastObserver < ActiveRecord::Observer
  def after_create(podcast)
    podcast.send_later(:async_create)
  end
end
