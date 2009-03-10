class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name(params[:tag])
    raise ActiveRecord::RecordNotFound if @tag.nil?

    @podcasts = @tag.podcasts
    @podcasts = @tag.podcasts.paginate(:page => (params[:page] || 1), :per_page => params[:limit] || 10)
  end

  def info
    @tag = Tag.find_by_name(params[:tag]) or raise ActiveRecord::RecordNotFound
    render :layout => 'info'
  end

  def info_index
    @tags = Tag.find(:all)
    render :layout => 'info'
  end

end
