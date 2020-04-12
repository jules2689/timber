require 'base64'

class LogRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'logs'
  document_type 'log'
  klass GenericLog

  settings number_of_shards: 1 do
    mapping do
      indexes :source, type: :text, fielddata: true
      indexes :application, type: :text, fielddata: true
      indexes :log, type: :text
      indexes :timestamp, type: :date
      indexes :id, type: :long
    end
  end
end
