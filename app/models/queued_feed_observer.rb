class QueuedFeedObserver < ActiveRecord::Observer
  def after_create(queued_feed)
    PodcastProcessor.send_later :process, queued_feed
    PodcastMailer.deliver_new_queued_feed(queued_feed)
  end
end
