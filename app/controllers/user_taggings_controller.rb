class UserTaggingsController < ApplicationController
  before_filter :login_required, :only => [:destroy]


  # POST /user_taggings
  def create
    @podcast = Podcast.find(params[:user_tagging][:podcast_id])

    if tags = params[:user_tagging].delete(:tag_string)
      tags.gsub(/,/,'').split.each do |tag|
        # Non-logged-in users are limimted to 8 claimable taggings
        break if !logged_in? && session[:unclaimed_records] && session[:unclaimed_records]['UserTagging'].size > 7

        # Try to add Tag, Tagging, and UserTagging for each tagstring
        Tag.connection.transaction do
          if tag = Tag.find_or_create_by_name(tag.strip.downcase)
            if tagging = @podcast.taggings.find_or_create_by_tag_id(tag.id)
              user_tagging = UserTagging.create!(:tagging => tagging, :user => current_user) 
              remember_unclaimed_record(user_tagging)
            end
          end
        end

      end
    end

    respond_to do |format|
      format.html { redirect_to(@podcast) }
      format.js { render :json => {:success => true, :html => render_to_string(:partial => "tags/tags_with_new_form", :object => @podcast.reload.tags, :locals => {:podcast => @podcast.reload}) } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { 
        flash[:notice] = "You are only allowed to add 8 tags for this podcast."
        redirect_to(@podcast)
      }
      format.js { render :json => {:success => false, :html => render_to_string(:partial => "tags/tags_with_new_form", :object => @podcast.reload.tags, :locals => {:podcast => @podcast.reload}) } }
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
