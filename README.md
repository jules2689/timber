# Timber

A local logging solution.

- Timber is a project that consumes simple text logs by piping the output of a local project.
- It allows for filtering using Elasticsearch querying, and can help you find logs by application, source in the app (assets, web, etc), and by time.

![Standard Mode](https://user-images.githubusercontent.com/3074765/79073918-3c416700-7cb7-11ea-81d2-73e71cdbf03d.png)

<details>
  <summary>Dark Mode</summary>

  <img src="https://user-images.githubusercontent.com/3074765/79073919-43687500-7cb7-11ea-9691-8750e12c6bcf.png" alt="Dark Mode Screenshot">

</details>

## To Run

1. `docker pull docker.pkg.github.com/jules2689/timber/timber:latest`
2. `docker run  -p 6778:3000 --name timber -v es-data:/var/lib/elasticsearch -t docker.pkg.github.com/jules2689/timber:latest`

_Note:_ The `-v` will mount in the `es-data` volume mount on your local machine. This will allow you to save Elasticsearch indices and data between runs of Docker.

## Data Sources

### Overmind

Timber can support logs from `overmind` applications by using the `overmind echo` feature. To send logs, create a bash file like this one:

```bash
#!/usr/bin/env sh

application=$1

while read var; do
  curl -H "Content-Type: application/text" -X POST -d "$var" "http://localhost:6778/logs?log_type=overmind&application=$application" >/dev/null 2>&1
done
```

Then call `overmind echo | /path/to/file APP_NAME`, replacing `APP_NAME` with the name of your application.

### json

Timber can support logs in JSON format too. As an example, this bash file should send logs much like the Overmind example:

```bash
#!/usr/bin/env sh

application=$1

while read var; do
  curl -H "Content-Type: application/json" -X POST -d '{ "log_type" : "json", "application" : "$application", "log": {...} }' "http://localhost:6778/logs" >/dev/null 2>&1
done
```

This likely isn't how you'd call the JSON functionality, you'd likely call it from within your app where you have structured access.

The key part is the json data is `{ "log_type" : "json", "application" : "$application", "log": {...} }`, and the endpoint is `http://localhost:6778/logs`

### URL encoded

```bash
#!/usr/bin/env sh

application=$1

while read var; do
  curl -X POST "http://localhost:6778/logs?log_type=url&application=$application&log=my_special_url_encoded_log" >/dev/null 2>&1
done
```
