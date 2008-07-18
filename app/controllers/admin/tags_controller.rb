class Admin::TagsController < AdminController
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all, :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find_by_name(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def merge
    @tag = Tag.find_by_name(params[:id])
    @merge_to = Tag.find_by_name(params[:name])
    raise ActiveRecord::NotFoundError unless @merge_to
    tag_count = 0

    Tagging.find_all_by_tag_id(@tag.id).each do |tagging|
      tagging.update_attribute(:tag_id, @merge_to.id)
      tag_count += 1
    end

    tag_name = @tag.name
    @tag.destroy

    flash[:notice] = "Merged #{tag_count} tags from '#{tag_name}' into '#{@merge_to.name}'."
    redirect_to admin_tags_path
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find_by_name(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to(admin_tags_path) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find_by_name(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(admin_tags_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find_by_name(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(admin_tags_path) }
      format.xml  { head :ok }
    end
  end
end
