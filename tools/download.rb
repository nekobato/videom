#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 5
  arg :help, 'show help', :alias => :h
  arg :min_speed, 'min download speed (kbps)', :default => 100
end

if parser.has_option? :help
  puts parser.help
  exit
end

class DownloadError < StandardError
end

loop do
  videos = Video.find_queue_download
  if videos.count > 0
    puts "#{videos.count} videos in queue"
    video = videos.first
    if video.url =~ /^http:\/\/himado.in\// and Video.not_in(:hide => [true]).where(:file.ne => nil, :url => video.url).count > 0
      video.skip_download = true
      puts "#{video.title} already downloaded, skipped. (#{video.video_url})"
      video.save
      next
    end
    puts "#{video.title} - #{video.url} (#{video.video_url})"
    fname = Digest::MD5.hexdigest(video.video_url)
    begin
      stream_count = 0
      start_at = Time.now.to_i
      open("#{@@dir}/#{fname}", 'w+'){|out|
        $VERBOSE = nil
        Curl::Easy.perform(video.video_url){|easy|
          easy.max_redirects = 5
          if video.http_opt
            easy.http_auth_types = [:basic, :digest]
            easy.username = video.http_opt['user']
            easy.password = video.http_opt['pass']
          end
          easy.on_body do |data|
            out.print data
            puts "#{easy.download_speed/1000}kbps" if (stream_count += 1) % 1000 == 0
            if Time.now.to_i-20 > start_at and easy.download_speed/1000 < parser[:min_speed].to_i
              raise DownloadError.new("download too slow (#{easy.download_speed/1000}kbps), #{stream_count} blocks received.")
            end
          end
        }
      }
      exif = MiniExiftool.new "#{@@dir}/#{fname}"
      raise "#{exif['mime_type']} is not video" unless exif['mime_type'] =~ /^video\/.+/i
      video[:file] = fname
      video[:download_at] = Time.now.to_i
      video.save
      puts "=> download complete"    
    rescue StandardError, Timeout::Error, DownloadError => e
      STDERR.puts e
      video.error_count += 1
      video.save      
    end
  end

  break unless parser[:loop]
  sleep parser[:interval].to_i
end
