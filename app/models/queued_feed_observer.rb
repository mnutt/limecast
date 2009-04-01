class FeedObserver < ActiveRecord::Observer
#  def after_create(feed)
#    PodcastMailer.deliver_new_feed(feed)
#    feed.send_later(:refresh)
#  end
end
