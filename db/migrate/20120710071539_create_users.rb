class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :access_token
      t.string :evernote_shard
      t.string :evernote_id

      t.timestamps
    end
  end
end
