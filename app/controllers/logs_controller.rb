class LogsController < ApplicationController
  include QueryParser
  before_action :set_aggregations, only: :index

  def index
    search_params = parse_query(params)
    logger.debug JSON.pretty_generate(search_params)
    @logs = LOG_REPO.search(search_params)
  end

  def create
    log = case params[:log_type]
    when "overmind"
      parse_overmind
    when "json", "url"
      parse_json_or_url
    end

    if log
      ActionCable.server.broadcast(
        "logs",
        log: log,
        partial: render(partial: "logs/log", locals: { log: log })
      )
    end

    head :no_content
  end

  private

  def parse_overmind
    original_log = request.body.read
    logger.debug original_log

    # Parse the log
    log = original_log.gsub(/\e\]0;/, '')

    # Find the source
    preamble, log = log.include?("\e[1m") ? log.split("\e[1m", 2) : log.split("\e[0m | ", 2)
    source, _ = Strings::ANSI.sanitize(preamble).split(" | ")
  
    # Save the log
    if source != "echo" && log&.strip&.present?
      tags = Strings::ANSI.sanitize(log).scan(/\[(\w+)\]/).map(&:first)
      new_log = GenericLog.new(
        'source' => source.strip,
        'log' =>  log.gsub(/(\[\w+\])/, '').strip,
        'application' => params[:application].strip,
        'tags' => tags,
      )
      LOG_REPO.save(new_log)
      return new_log
    end

    nil
  end

  def parse_json_or_url
    new_log = GenericLog.new(
      'source' => params[:source]&.strip,
      'log' =>  params[:log],
      'application' => params[:application]&.strip
    )
    LOG_REPO.save(new_log)
    new_log
  end

  def set_aggregations
    @aggregations ||= begin
      query = {
        size: 0,
        aggs: {
          applications: { terms: { field: "application",  size: 500 } },
          sources: { terms: { field: "source",  size: 500 } }
        }
      }
      response = LOG_REPO.search(query)
      aggregations = response.raw_response["aggregations"]
      aggregations.map { |k, v| [k, v["buckets"].map { |b| b["key"] }.sort] }.to_h
    end
  end
end
