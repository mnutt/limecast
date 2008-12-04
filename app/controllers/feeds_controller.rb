class FeedsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :status

  def create
    if @feed = Feed.find_by_url(params[:feed][:url])
      @feed.update_attribute(:state, "pending") if @feed.state == "failed"
      @feed.send_later(:refresh)
    else
      @feed = Feed.new(params[:feed])
      @feed.finder = current_user
    end

    respond_to do |format|
      format.js do
        if @feed.save
          render :nothing => true, :status => 200
        else
          render :nothing => true, :status => 500
        end
      end
      format.html do
        @feed.save
        redirect_to podcast_url(@feed.podcast)
      end
    end
  end

  def status
    @feed    = Feed.find_by_url(params[:feed])
    @podcast = @feed.podcast unless @feed.nil?

    # See http://wiki.limewire.org/index.php?title=LimeCast_Add#Messages
    # Unexpected errors
    if @feed.nil?
      render :partial => 'status_error'
    # Successes
    elsif @podcast && @feed.parsed? && feed_created_just_now_by_user?(@feed)
      render :partial => 'status_added'
    # Expected errors
    elsif @feed.failed? || @podcast && @feed.parsed?
      render :partial => 'status_failed'
    # Progress
    elsif @feed.pending?
      render :partial => 'status_loading'
    # Really unexpected errors
    else
      render :partial => 'status_error'
    end
  end

  def update
    @feed = Feed.find params[:id]
    authorize_write @feed

    respond_to do |format|
      format.js do
        if @feed.update_attributes(params[:feed])
          render :nothing => true, :status => 200
        else
          render :nothing => true, :status => 500
        end
      end
    end
  end

  def destroy
    @feed = Feed.find params[:id]
    @podcast = @feed.podcast
    authorize_write @feed

    respond_to do |format|
      format.js do
        if @feed.destroy
          render :nothing => true, :status => 200
        else
          render :nothing => true, :status => 500
        end
      end
      format.html do
        @feed.destroy
        redirect_to podcast_url(@podcast)
      end
    end
  end

  protected

    def feed_in_session?(feed)
      (session.data[:feeds] and session.data[:feeds].include?(feed.id))
    end

    def feed_created_by_user?(feed)
      feed_in_session?(feed) or feed.writable_by?(current_user)
    end

    def feed_created_just_now_by_user?(feed)
      feed_created_by_user?(feed) && feed.just_created?
    end
end
