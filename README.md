# Timber

A local logging solution.

- Timber is a project that consumes simple text logs by piping the output of a local project.
- It allows for filtering using ElasticSearch querying, and can help you find logs by application, source in the app (assets, web, etc), and by time.

### Overmind

Timber can support logs from `overmind` applications by using the `overmind echo` feature. To send logs, create a bash file like this one:

```bash
#!/usr/bin/env sh

application=$1

while read var; do
  curl -H "Content-Type: application/text" -X POST -d "$var" "http://localhost:6778/logs?log_type=overmind&application=$application" >/dev/null 2>&1
done
```

Then call `overmind echo | /path/to/file APP_NAME`, replacing `APP_NAME`.
