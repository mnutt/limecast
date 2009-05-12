class FeedsController < ApplicationController
  def show
    @feed = Feed.find params[:id]

    render :xml => @feed.as(params[:type])
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

  def add_info
    @exception = YAML.load_file("#{RAILS_ROOT}/log/last_add_failed.yml")
    render :layout => 'info'
  end

  def hash_info
    @sources = Source.find(:all, :conditions => ["hashed_at > ?", 3.days.ago],
                           :limit => 40,
                           :order => "hashed_at DESC")
    @sources_count = Source.count
    @unhashed_count = Source.stale.count
    @hashed_count = @sources_count - @unhashed_count
    @percentage = (@hashed_count.to_f / @sources_count.to_f * 100).to_i
    @last_day = Source.count(:conditions => ["hashed_at > ?", 1.day.ago])

    @probably_next_source = Source.stale.find(:first, :order => "id DESC")
    @hashing_tail = `tail -n 40 #{RAILS_ROOT}/log/update_sources.log`

    render :layout => 'info'
  end
end
