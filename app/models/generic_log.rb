class GenericLog
  attr_reader :attributes, :timestamp

  def initialize(attributes={})
    @attributes = attributes
    @timestamp = Time.now.utc
  end

  def type
    :log
  end

  def to_hash
    @attributes.merge(timestamp: @timestamp)
  end
end