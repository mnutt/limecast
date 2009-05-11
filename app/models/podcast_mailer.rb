class PodcastMailer < ActionMailer::Base
  FROM_HOST = "limecast.com"

  def new_queued_feed(queued_feed)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added queued feed: #{queued_feed.url}"
    body    :queued_feed => queued_feed, :host => FROM_HOST
  end

  def failed_queued_feed(queued_feed, exception)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Failed queued feed: #{queued_feed.url}"
    body    :queued_feed => queued_feed, :exception => exception, :host => FROM_HOST
  end

  def new_podcast(podcast)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added podcast: #{podcast.title}"
    body    :podcast => podcast, :host => FROM_HOST
  end
end
