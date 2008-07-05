require File.dirname(__FILE__) + '/../spec_helper'

describe CategoriesController, "GET show" do
  scenario :categories

  before do
    @category = categories(:default)

    get :show, :id => @category.id
  end

  it 'should have set the category' do
    assigns(:category).should == @category
  end
end

describe CategoriesController, "GET index" do
  scenario :categories

  before do
    @categories = [categories(:default)]

    get :index
  end

  it 'should have set the categories' do
    assigns(:categories).should == @categories
  end
end
