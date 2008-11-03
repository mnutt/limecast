class CommentsController < ApplicationController
  before_filter :login_required, :only => [:new, :update]

  def index
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @feeds   = @podcast.feeds

    @comments = filter(@podcast.comments, params[:filter])
  end

  def show
    @comment = Comment.find(params[:id])

    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @feeds   = @podcast.feeds
  end

  def new
    @comment = Comment.new
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @feeds   = @podcast.feeds
  end

  def edit
    @comment = Comment.find(params[:id])
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @feeds   = @podcast.feeds

    redirect_to(:back) rescue redirect_to('/') unless @comment.editable?
  end

  def create
    comment_params = params[:comment].keep_keys([:title, :body, :positive, :episode_id])
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if current_user
        @comment.commenter = current_user

        if @comment.save
          format.html { redirect_to :back }
          format.js
        else
          format.html { render :action => "new" }
        end
      else
        session[:comment] = comment_params
        format.js
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to :back }
      else
        format.html { render :action => "edit" }
      end

      format.js { render :nothing => true }
    end
  end

  def rate
    session[:comments_rated] ||= []

    unless session[:comments_rated].include?(params[:id])
      @comment = Comment.find(params[:id])

      case params[:rating]
      when /not/
        @comment.update_attributes(:not_insightful => @comment.not_insightful + 1)
      when /insightful/
        @comment.update_attributes(:insightful => @comment.insightful + 1)
      end

      session[:comments_rated] << params[:id]
    end

    redirect_to(:back)
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    session.data[:comments].delete(params[:id])

    respond_to do |format|
      format.js   { render :nothing => true }
      format.html { redirect_to episode_url(@comment.episode.podcast, @comment.episode) }
    end
  end

  protected

  def filter(comments, f)
    case f
    when "positive": comments.that_are_positive
    when "negative": comments.that_are_negative
    else comments
    end
  end

end
