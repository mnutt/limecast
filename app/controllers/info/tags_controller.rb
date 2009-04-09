class Info::TagsController < InfoController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find_by_name!(params[:tag])
  end
end

