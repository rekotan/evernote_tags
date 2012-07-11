class EvernoteTag
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :guid, :name, :parent_guid, :update_sequence_num
  attr_accessor :tag_count
  validates :name, :presence => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end

