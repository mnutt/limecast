class QuickFeedObserver < ActiveRecord::Observer
  def after_create(quick_feed)
    #PodcastMailer.deliver_new_feed(feed)
    FeedProcessor.send_later :process, quick_feed
  end
end
