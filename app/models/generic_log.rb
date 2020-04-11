class GenericLog
  attr_reader :attributes

  def initialize(attributes={})
    @attributes = attributes
    @timestamp = Time.new
  end

  def type
    :log
  end

  def to_hash
    @attributes.merge(timestamp: @timestamp)
  end
end