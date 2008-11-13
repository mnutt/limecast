class FeedObserver < ActiveRecord::Observer
  def after_create(feed)
    feed.send_later(:refresh)
  end
end
