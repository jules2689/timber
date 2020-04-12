ES_CLIENT = Elasticsearch::Client.new(url: 'http://localhost:9200', log: false)
LOG_REPO = LogRepository.new(client: ES_CLIENT)

if ENV['SETUP_ES']
  unless LOG_REPO.index_exists?
    LOG_REPO.create_index!(force: true)
  end
end
