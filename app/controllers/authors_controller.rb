class AuthorsController < ApplicationController
  def show
    @author = Author.find_by_clean_url(params[:author_slug])
    raise ActiveRecord::RecordNotFound if @author.nil?
  end
end