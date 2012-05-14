
before do
  @title = 'videom'
end

get '/' do
  @per_page = params['per_page'].to_i
  @per_page = Conf['per_page'] if @per_page < 1
  @page = params['page'].to_i
  @page = 1 if @page < 1
  videos = Video.find_availables.desc(:_id)
  @video_count = videos.count
  @videos = videos.skip(@per_page*(@page-1)).limit(@per_page)
  haml :index
end

get '/tag/:tag' do
  @tag = params[:tag].to_s
  @per_page = params['per_page'].to_i
  @per_page = Conf['per_page'] if @per_page < 1
  @page = params['page'].to_i
  @page = 1 if @page < 1
  videos = Video.find_by_tag(@tag).desc(:_id)
  @video_count = videos.count
  @videos = videos.skip(@per_page*(@page-1)).limit(@per_page)
  haml :index
end

get '/search/:word' do
  @word = params[:word]
  @per_page = params['per_page'].to_i
  @per_page = Conf['per_page'] if @per_page < 1
  @page = params['page'].to_i
  @page = 1 if @page < 1
  videos = Video.find_by_word(@word).desc(:_id)
  @video_count = videos.count
  @videos = videos.skip(@per_page*(@page-1)).limit(@per_page)
  haml :index
end

get '/v/*.mp4' do
  @vid = params[:splat].first.to_s
  @video = Video.find(@vid) rescue @video = nil
  unless @video
    status 404
    @mes = "video file (#{@vid}) not found."
  else
    redirect "#{app_root}/#{Conf['video_dir']}/#{@video.file}"
  end
end

get '/v/:id' do
  @vid = params[:id].to_s
  @video = Video.find(@vid) rescue @video = nil
  if !@video or !@video.available?
    status 404
    @mes = "video (#{@vid}) not found."
  else
    haml :video
  end
end

get '/stats' do
  @stats = Video.stats
  haml :stats
end
