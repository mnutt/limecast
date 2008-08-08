require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/users/edit.html.erb" do
  before do
    @user = mock_model(User)
    assigns[:user] = @user
  end

  it "should render edit form" do
    render "/admin/users/edit.html.erb"

    response.should have_tag("form[action=#{admin_user_path(@user)}][method=post]") do
    end
  end
end


