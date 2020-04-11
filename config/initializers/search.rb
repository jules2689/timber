ES_CLIENT = Elasticsearch::Client.new(url: 'http://localhost:9200', log: false)
LOG_REPO = LogRepository.new(client: ES_CLIENT)
# LOG_REPO.create_index!(force: true)
