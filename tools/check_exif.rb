#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/init'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop', false)
parser.bind(:interval, :i, 'loop interval (sec)', 5)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if parser.has_option(:help)
  puts parser.help
  exit
end

loop do
  videos = Video.find_queue_checkexif
  puts "#{videos.count} files in queue"
  videos.each do |v|
    file = "#{@@dir}/#{v.file}"
    puts "#{v.title} - #{file}"
    begin
      exif = MiniExiftool.new file
      raise "#{exif['mime_type']} is not video file" unless exif['mime_type'] =~ /^video\/.+/i
      if !(exif['mime_type'] =~ /^video\/mp4$/i)
        if exif['video_encoding'] =~ /^H.264$/i
          vcodec = 'copy'
          opt = "-ac 2"
        else
          vcodec = 'libx264'
          opt = "-vpre default -ac 2"
        end
        acodec = exif['audio_encoding'] =~ /^AAC$/i ? 'copy' : 'libfaac'
        file_mp4 = "#{file}.mp4"
        puts cmd = "ffmpeg -y -i #{file} -vcodec #{vcodec} -acodec #{acodec} #{opt} #{file_mp4}"
        system cmd
        File.delete file
        file = file_mp4
        exif = MiniExiftool.new file
      end
    rescue => e
      STDERR.puts e
      File.delete file if File.exists? file
      v.hide = true
      v.file = nil
      v.save
      next
    end
    ext = exif['FileType'].downcase
    v.file += ".#{ext}" unless v.file =~ /.+\.#{ext}$/i
    File.rename(file, "#{@@dir}/#{v.file}") rescue next
    puts " => #{v.file}"
    v.exif = exif.to_hash
    p v.exif
    v.save
  end
  break unless params[:loop]
  sleep params[:interval].to_i
end


