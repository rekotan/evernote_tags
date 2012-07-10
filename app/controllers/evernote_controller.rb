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

  def list_tags
    note_store.listTags(current_user.access_token).map do |tag|
      EvernoteTag.new(guid: tag.guid, name: tag.name,
                      parent_guid: tag.parentGuid, update_sequence_num: tag.updateSequenceNum)
    end
  end

  def note_count(note_filter={:tag_guid=>'', :with_trash=>false})
    note_counts = note_store.findNoteCounts(current_user.access_token,
                              Evernote::EDAM::NoteStore::NoteFilter.new(:tagGuids => [note_filter[:tag_guid]]),
                              note_filter[:with_trash])
    if note_counts.notebookCounts
      note_counts.notebookCounts.values.sum
    else
      0
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

  def update_tag(evernote_tag)
    tag = note_store.getTag(current_user.access_token, evernote_tag.guid)
    tag.name = evernote_tag.name
    note_store.updateTag(current_user.access_token, tag)
  end

  def delete_tag(guid)
    note_store.expungeTag(current_user.access_token, guid)
  end

end
