class Info::UsersController < InfoController
  def index
    @users = User.find(:all, :order => 'login ASC')
  end
  
  def show
    @user = User.find_by_login(params[:user_slug]) or raise ActiveRecord::RecordNotFound
  end
end

