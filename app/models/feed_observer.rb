class FeedObserver < ActiveRecord::Observer
  def after_create(feed)
    feed.send(:async_create)
  end
end
