client = Elasticsearch::Client.new(url: 'http://localhost:9200', log: true)
repository = LogRepository.new(client: client)
repository.create_index!(force: true)
puts repository.index_name

log = GenericLog.new('id' => 1, 'source' => 'log', 'log' => 'foo=bar ip=127.0.0.1 banana=apple')
LOG_REPO.save(log)


log = GenericLog.new('id' => 2, 'source' => 'log', 'log' => 'foo=baz ip=127.0.0.1 banana=apple')
LOG_REPO.save(log)


log = GenericLog.new('id' => 3, 'source' => 'log', 'log' => 'foo=banana ip=127.0.0.1 banana=apple')
LOG_REPO.save(log)

sleep 1

repo = repository.find(1, 2, 3)

results = repository.search(query: { match: { log: 'foo=bar' } })
results.each_with_hit do |log, hit|
  puts "* #{log.attributes["log"]}, score: #{hit["_score"]}"
end
