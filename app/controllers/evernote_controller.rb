class EvernoteController < ApplicationController

  private
  def user_store
    userStoreUrl = "#{ENV['EVERNOTE_SITE']}/edam/user"
    userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
    userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
    userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)
    versionOK = userStore.checkVersion("Evernote EDAMTest (Ruby)",
                                       Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
                                       Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
    raise 'API version is not up to date' if !versionOK
    userStore
  end

  def note_store
    noteStoreUrl = user_store.getNoteStoreUrl(current_user.access_token)
    noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    @noteStore ||= Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
  end

  def list_tags(with_trash=false)
    note_counts = note_store.findNoteCounts(current_user.access_token,
                                            Evernote::EDAM::NoteStore::NoteFilter.new,
                                            with_trash)
    note_store.listTags(current_user.access_token).map do |tag|
      EvernoteTag.new(guid: tag.guid, name: tag.name,
                      parent_guid: tag.parentGuid, update_sequence_num: tag.updateSequenceNum,
                      tag_count: note_counts.tagCounts[tag.guid] || 0)
    end
  end

  def get_tag(guid)
    tag = note_store.getTag(current_user.access_token, guid)
    EvernoteTag.new(guid: tag.guid, name: tag.name,
                    parent_guid: tag.parentGuid, update_sequence_num: tag.updateSequenceNum)
  end

  def create_tag(evernote_tag)
    note_store.createTag(current_user.access_token,
                         Evernote::EDAM::Type::Tag.new(:name => evernote_tag.name))
  end

  def update_tag(guid, values={})
    unless values.empty?
      tag = note_store.getTag(current_user.access_token, guid)
      values.each{|k,v| tag.send("#{k}=".to_sym, v)}
      note_store.updateTag(current_user.access_token, tag)
    end
  end

  def delete_tag(guid)
    note_store.expungeTag(current_user.access_token, guid)
  end

  def handle_evernote
    begin
      yield
    rescue Evernote::EDAM::Error::EDAMUserException => e
      raise "UnexpectedError: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}(#{e.errorCode})"
    end
  end

  [:list_tags, :get_tag, :create_tag, :update_tag, :delete_tag].each do |m|
    n = "#{m}_old".to_sym
    alias_method n, m
    define_method(m) do |*arg|
      handle_evernote{method(n).call(*arg)}
    end
  end

end
