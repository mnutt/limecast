class PodcastObserver < ActiveRecord::Observer
  def after_create(podcast)
    podcast.async_send(:async_create)
  end
end
