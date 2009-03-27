class UserTaggingsController < ApplicationController
  before_filter :login_required, :only => [:destroy]


  # POST /user_taggings
  def create
    @podcast = Podcast.find(params[:user_tagging][:podcast_id])

    if tags = params[:user_tagging].delete(:tag_string)
      tags.gsub!(/,/, '')
      @podcast.update_attribute :tag_string, [tags, current_user]
      flash[:display_edit_form] = true
    end

    respond_to do |format|
      format.js { render :json => {:success => true, :html => render_to_string(:partial => "tags/tags_with_new_form", :object => @podcast.reload.tags, :locals => {:podcast => @podcast.reload}) } }
      format.html { redirect_to(@podcast) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = "You are only allowed to add 8 tags for this podcast."
    flash[:display_edit_form] = false

    respond_to do |format|
      format.js { render :json => {:success => false } }
      format.html { redirect_to(@podcast) }
    end
  end
  
  # DELETE /user_tagging/:id
  def destroy
    @user_tagging = UserTagging.find(params[:id])

    authorize_write @user_tagging
    
    respond_to do |format|
      if @user_tagging.destroy
        format.js { render :layout => false }
      else
        format.js { head 404 }
      end
    end
  end

end
