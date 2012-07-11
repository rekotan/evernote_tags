class TagsController < EvernoteController
  before_filter :authenticate_user!

  def index
    begin
      @tags = list_tags.sort{|a,b| a.name <=> b.name}
    rescue => e
      redirect_to home_logout_path, :alert => e.message
    end
  end

  def new
    @tag = EvernoteTag.new
  end

  def create
    begin
      create_tag(EvernoteTag.new(params[:evernote_tag]))
      redirect_to tags_index_path, :notice => "Tag is successfully created"
    rescue => e
      redirect_to tags_index_path, :alert => e.message
    end
  end

  def edit
    @tag = get_tag(params[:guid])
  end

  def update
    begin
      update_tag(params[:evernote_tag][:guid], :name => params[:evernote_tag][:name])
      redirect_to tags_index_path, :notice => "Tag is successfully updated"
    rescue => e
      redirect_to tags_index_path, :alert => e.message
    end
  end

  def destroy
    begin
      delete_tag(params[:guid])
      redirect_to tags_index_path, :notice => "Tag is successfully deleted"
    rescue => e
      redirect_to tags_index_path, :alert => e.message
    end
  end

end
