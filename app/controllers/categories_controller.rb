class CategoriesController < ApplicationController
  def index
    @categories = Category.find(:all, :order => 'position ASC')
  end

  def show
    @category = Category.find params[:id]
  end
end
