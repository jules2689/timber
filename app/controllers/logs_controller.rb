class LogsController < ApplicationController
  include QueryParser
  def index
    search_params = parse_query(params)
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
