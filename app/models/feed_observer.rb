class FeedObserver < ActiveRecord::Observer
  def after_create(feed)
    feed.send(:refresh)
  end
end
