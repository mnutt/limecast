class FeedsController < ApplicationController
  def create
    @podcast = Podcast.find params[:feed].delete(:podcast_id)
    @feed = Feed.new(params[:feed])
    @feed.finder = current_user
    
    if @feed.similar_to_podcast?(@podcast)
      if @feed.save
        render :status => 200
      else
        render :status => 500
      end
    else
      render :status => 500, :partial => "feed_does_not_match_podcast"
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

end
