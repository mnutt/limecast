class PodcastMailer < ActionMailer::Base
  FROM_HOST = "limecast.com"

  def new_feed(feed)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added feed: #{feed.url}"
    body    :feed => feed, :host => FROM_HOST
  end

  def failed_feed(feed, exception)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Failed feed: #{feed.url}"
    body    :feed => feed, :exception => exception, :host => FROM_HOST
  end

  def new_podcast(podcast)
    @recipients = ExceptionNotifier.exception_recipients
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now

    subject "[LimeCast] Added podcast: #{podcast.title}"
    body    :podcast => podcast, :host => FROM_HOST
  end
  
  def updated_podcast(podcast)
    @recipients = podcast.editors.map &:email
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now
    
    subject "A podcast you can edit was changed."
    body    :podcast => podcast, :host => FROM_HOST
  end
end
