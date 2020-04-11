class LogsController < ApplicationController
  def index
    search_params = { size: 1000, sort: [{ timestamp: "desc" }] }

    queries = []
    queries << { match: { application: params[:application] } } if params[:application].present?
    queries << { match: { source: params[:source] } } if params[:source].present?
    queries << { match: { log: params[:log] } } if params[:log].present?

    time_query = nil
    if params[:time_range]
      from_time, to_time = params[:time_range].split(" - ")
      time_query = {
        range: {
          "timestamp" => {
              gte: DateTime.parse(from_time).utc.iso8601[0..-2],
              lte: DateTime.parse(to_time).utc.iso8601[0..-2]
          }
        }
      }
    end

    if queries.empty?
      if time_query.nil?
        search_params[:query] = { match_all: {} }
      else
        search_params[:query] = time_query
      end
    else
      queries << time_query if time_query
      search_params[:query] = { bool: { must: queries } }
    end

    # search_params[:filter] = { kv: {} }

    puts JSON.pretty_generate(search_params)
    @logs = LOG_REPO.search(search_params)
  end

  def new
  end

  def create
    original_log = request.body.read
    puts original_log

    # Parse the log
    log = original_log.gsub(/\e\]0;/, '')

    # Find the source
    preamble, log = log.include?("\e[1m") ? log.split("\e[1m", 2) : log.split("\e[0m | ", 2)
    source, _ = Strings::ANSI.sanitize(preamble).split(" | ")
  
    if source != "echo" && log&.strip&.present?
      tags = Strings::ANSI.sanitize(log).scan(/\[(\w+)\]/).map(&:first)
      new_log = GenericLog.new(
        'source' => source.strip,
        'log' =>  log.gsub(/(\[\w+\])/, '').strip,
        'application' => params[:application].strip,
        'tags' => tags,
      )
      LOG_REPO.save(new_log)
    end

    head :no_content
  end
end
