class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name(params[:tag])
    @podcasts = @tag.taggings.map{|tagging| tagging.taggable}.compact
  end
end
