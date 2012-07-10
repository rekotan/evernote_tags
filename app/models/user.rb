class User < ActiveRecord::Base
  attr_accessible :access_token, :evernote_id, :evernote_shard
end
