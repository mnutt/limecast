class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name(params[:tag])
    raise ActiveRecord::RecordNotFound if @tag.nil?

    @podcasts = @tag.podcasts
  end

  def search
    @q = params[:q]
    @tag = Tag.find_by_name(params[:tag])
    raise ActiveRecord::RecordNotFound if @tag.nil?

    # FIXME This is a hack; you should be able to do Podcast.search(@q, :with => {:tagged_ids => @tag.id}).compact,
    #       but that's pulling up podcasts outside of the tag right now... (look at Reviews#search for
    #       a working example :O
    @podcasts = Podcast.search(@q, :include => [:tags]).compact.select { |p| p.tags.include?(@tag) }
    render :action => 'show'
  end

  def info
    @tag = Tag.find_by_name(params[:tag]) or raise ActiveRecord::RecordNotFound
    render :layout => false
  end

  def info_index
    @tags = Tag.find(:all)
    render :layout => false
  end

end
