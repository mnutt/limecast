class FeedObserver < ActiveRecord::Observer
  def after_create(feed)
    feed.send_later(:async_create)
  end
end
