class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name!(params[:tag])
    @podcasts = @tag.podcasts.paginate(:page => (params[:page] || 1), :per_page => params[:limit] || 10)
  end
end
