
before '/*.json' do
  content_type 'application/json'
end

get '/stats.json' do
  @mes = Video.stats.to_json
end

get '/v/*.json' do
  @vid = params[:splat].first.to_s
  begin
    @video = Video.find(@vid)
    raise "video (#{@vid}) not found" if !@video or !@video.available?
    @mes = @video.to_hash.to_json
  rescue => e
    STDERR.puts e
    @mes = {
      :error => true,
      :message => e
    }.to_json
  end
end

post '/v/*.json' do
  @vid = params[:splat].first.to_s
  begin
    @video = Video.find(@vid)
    raise "video (#{@vid}) not found" if !@video or !@video.available?
    if params['tags']
      @tags = params['tags'].delete_if{|tag| tag.to_s.size < 1}.uniq rescue @tags = []
      @video.tags = @tags
    end
    if params['title']
      @video.title = params['title']
    end
    @video.save
    @mes = {
      :error => false,
      :data => @video.to_hash
    }.to_json
  rescue => e
    STDERR.puts e
    @mes = {
      :error => true,
      :message => e.to_s
    }.to_json
  end
end

delete '/v/:id' do
  @vid = params[:id].to_s
  begin
    video = Video.find(@vid)
    video.delete_file!
  rescue => e
    STDERR.puts e
    status 404
    @mes = {
      :error => true,
      :message => e.to_s
    }.to_json
  end
  @mes = {
    :error => false,
    :message => "video #{@vid} deleted"
  }.to_json
end
