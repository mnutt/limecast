class PodcastMailer < ActionMailer::Base
  FROM_HOST = "limecast.com"

  def new_queued_podcast(queued_podcast)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added queued feed: #{queued_podcast.url}"
    body    :queued_podcast => queued_podcast, :host => FROM_HOST
  end

  def failed_queued_podcast(queued_podcast, exception)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Failed queued feed: #{queued_podcast.url}"
    body    :queued_podcast => queued_podcast, :exception => exception, :host => FROM_HOST
  end

  def new_podcast(podcast)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added podcast: #{podcast.title}"
    body    :podcast => podcast, :host => FROM_HOST
  end
end
