class UserTaggingsController < ApplicationController
  before_filter :login_required
  
  # DELETE /user_tagging/:id
  def destroy
    @user_tagging = UserTagging.find(params[:id])

    authorize_write @user_tagging
    
    respond_to do |format|
      if @user_tagging.destroy
        format.js { render :layout => false }#'users/destroy.js.erb' }
      else
        format.js { head 404 }
      end
    end
  end

end
