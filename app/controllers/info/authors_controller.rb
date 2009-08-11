class Info::AuthorsController < InfoController
  def index
    @authors = Author.find(:all, :order => 'name ASC')
  end
  
  def show
    @author = Author.find_by_name(params[:author_slug]) or raise ActiveRecord::RecordNotFound
  end
end

