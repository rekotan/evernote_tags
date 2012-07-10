class TagsController < EvernoteController
  before_filter :authenticate_user!

  def index
    @tags = list_tags
    @note_counts = Hash[@tags.map{|tag| [tag.name, note_count(:tag_guid => tag.guid)]}]
  end

  def new
    @tag = EvernoteTag.new
  end

  def create
    begin
      create_tag(EvernoteTag.new(params[:evernote_tag]))
      redirect_to tags_index_path, :notice => "Tag is successfully created"
    rescue Evernote::EDAM::Error::EDAMUserException => e
      redirect_to tags_index_path, :alert => "UnexpectedError: #{e.inspect}"
    end
  end

  def edit
    @tag = get_tag(params[:guid])
  end

  def update
    tag = get_tag(params[:evernote_tag][:guid])
    tag.name = params[:evernote_tag][:name]
    begin
      update_tag(tag)
      redirect_to tags_index_path, :notice => "Tag is successfully updated"
    rescue Evernote::EDAM::Error::EDAMUserException => e
      redirect_to tags_index_path, :alert => "UnexpectedError: #{e.inspect}"
    end
  end

  def destroy
    begin
      delete_tag(params[:guid])
      redirect_to tags_index_path, :notice => "Tag is successfully deleted"
    rescue Evernote::EDAM::Error::EDAMUserException => e
      redirect_to tags_index_path, :alert => "UnexpectedError: #{e.inspect}"
    end
  end

end
