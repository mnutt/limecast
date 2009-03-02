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
  
  # A user edited your podcast on the site
  def updated_podcast_from_site(podcast)
    @recipients = podcast.editors.reject {|e| e.email !~ /\@limewire\.com$/ }.map(&:email)
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now
    
    subject "A podcast you can edit was changed."
    body    :podcast => podcast, :host => FROM_HOST
  end

  # A feed for your podcast changed and the podcast was updated
  def updated_podcast_from_feed(podcast)
    @recipients = podcast.editors.reject {|e| e.email !~ /\@limewire\.com$/ }.map(&:email)
    @from       = "LimeCast <podcasts@limewire.com>"
    @sent_on    = Time.now
    
    subject "A podcast you can edit was changed."
    body    :podcast => podcast, :host => FROM_HOST
  end
end
