
def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def next_page_url
  if @tag
    return "#{app_root}/tag/#{@tag}?page=#{@page+1}&per_page=#{@per_page}"
  elsif @word
    return "#{app_root}/search/#{@word}?page=#{@page+1}&per_page=#{@per_page}"
  else
    return "#{app_root}/?page=#{@page+1}&per_page=#{@per_page}"
  end
end

def prev_page_url
  if @tag
    return "#{app_root}/tag/#{@tag}?page=#{@page-1}&per_page=#{@per_page}"
  elsif @word
    return "#{app_root}/search/#{@word}?page=#{@page-1}&per_page=#{@per_page}"
  else
    return "#{app_root}/?page=#{@page-1}&per_page=#{@per_page}"
  end
end
