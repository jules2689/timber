module QueryParser
  def parse_query(params)
    search_params = { size: 1000, sort: [{ timestamp: "desc" }] }

    queries = []
    queries << { match: { application: params[:application] } } if params[:application].present?
    queries << { match: { source: params[:source] } } if params[:source].present?
    queries << log_query(params[:log]) if params[:log].present?

    time_query = time_query(params)
    queries << time_query if time_query

    search_params[:query] = queries.empty? ? { match_all: {} } : { bool: { must: queries } }
    search_params
  end

  def log_query(log)
    {
      simple_query_string: {
        query: log
      }
    }
  end

  def time_query(params)
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
    time_query
  end
end
