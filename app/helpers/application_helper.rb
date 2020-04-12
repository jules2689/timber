module ApplicationHelper
  def octicon(*args)
    icon = Octicons::Octicon.new(*args)
    icon.to_svg.html_safe
  end

  def search_url(modified_params)
    new_params = request.query_parameters.merge(modified_params)
    "/?#{new_params.to_query}"
  end

  def parse_log(log)
    return unless log
    parsed = log.gsub(/\\n/, "\n")
    parsed = parsed.gsub(/\\r/, '')
    parsed = parsed.gsub(' | ', "\n")
    parsed = parsed.gsub(/ +/, ' ')
    parsed
  end
end
