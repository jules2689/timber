module ApplicationHelper
  def octicon(*args)
    icon = Octicons::Octicon.new(*args)
    icon.to_svg
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

  def escape_to_html(data)
    { 1 => :nothing,
      2 => :nothing,
      4 => :nothing,
      5 => :nothing,
      7 => :nothing,
      30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
      40 => :nothing,
      41 => :nothing,
      43 => :nothing,
      44 => :nothing,
      45 => :nothing,
      46 => :nothing,
      47 => :nothing,
    }.each do |key, value|
      if value != :nothing
        data.gsub!(/\e\[#{key}m/,"<span style=\"color:#{value}\">")
      else
        data.gsub!(/\e\[#{key}m/,"<span>")
      end
    end
    data.gsub!(/\e\[0m/,'</span>')
    return data
  end
end
