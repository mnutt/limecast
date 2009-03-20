class UserTaggingsController < ApplicationController
  before_filter :login_required


  # POST /user_taggings
  def create
    @podcast = Podcast.find(params[:user_tagging][:podcast_id])

    if tags = params[:user_tagging].delete(:tag_string)
      tags.gsub!(/,/, '')
      @podcast.update_attribute :tag_string, [tags, current_user]
    end

    redirect_to(@podcast)
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = "You are only allowed to add 8 tags for this podcast."
    redirect_to(@podcast)
  end
  
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
