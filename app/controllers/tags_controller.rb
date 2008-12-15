class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name(params[:tag])
    # XXX: @tag.podcasts
    @podcasts = @tag.podcasts
  end
end
