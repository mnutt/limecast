class Info::TagsController < InfoController
  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find_by_name!(params[:tag])
  end
end

