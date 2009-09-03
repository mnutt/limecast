class QueuedPodcastObserver < ActiveRecord::Observer
  def after_create(queued_podcast)
    PodcastProcessor.send_later :process, queued_podcast
    # PodcastMailer.deliver_new_queued_podcast(queued_podcast)
  end
end
