class QueuedFeedObserver < ActiveRecord::Observer
  def after_create(queued_feed)
    FeedProcessor.send_later :new, queued_feed
    PodcastMailer.deliver_new_feed(queued_feed)
  end
end
