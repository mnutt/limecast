class CommentsController < ApplicationController
  before_filter :login_required, :only => [:new, :update]

  def index
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @comments = filter(@podcast.comments, params[:filter])
  end

  def show
    @comment = Comment.find(params[:id])
  end

  def new
    @comment = Comment.new
  end

  def edit
    @comment = Comment.find(params[:id])

    redirect_to(:back) rescue redirect_to('/') unless @comment.editable?
  end

  def create
    @comment = Comment.new(params[:comment].keep_keys([:title, :body, :positive, :episode_id]))
    @comment.commenter = current_user unless current_user.nil?

    respond_to do |format|
      if @comment.save
        if !current_user
          session.data[:comments] ||= []
          session.data[:comments] << @comment.id
        end

        flash[:notice] = 'Comment was successfully added.'
        format.html { redirect_to episode_url(@comment.episode.podcast, @comment.episode) }
        format.js { render :partial => 'comments/comment', :object => @comment }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully updated.'
      redirect_to url_for([@comment.commentable])
    else
      render :action => "edit"
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
