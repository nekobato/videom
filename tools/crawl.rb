#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 600
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help
  puts parser.help
  exit
end

himado = Himado.new

loop do
  Conf['tags'].each{|tag|
    puts "tag : #{tag}"
    begin
      videos = himado.videos_page(Conf['crawl_page'], :keyword => tag)
    rescue StandardError, Timeout::Error => e
      STDERR.puts e
      next
    end
    videos.each{|v|
      begin
        video = himado.video(v[:url])
      rescue => e
        STDERR.puts e
        next
      rescue Timeout::Error => e
        STDERR.puts e
        next
      end
      puts video[:title] + ' - ' + video[:url]
      video[:video_urls].each do |url|
        next if url.to_s.size < 1 or !(url.to_s =~ /^https?:\/\/.+/)
        v = {:video_url => url}
        video.keys.each do |k|
          next if k == :video_urls
          v[k] = video[k]
        end
        v[:crawl_at] = Time.now.to_i
        unless Video.where(:video_url => url).count > 0
          puts " => saved! (#{url})" if Video.new(v).save
        end
      end
      sleep 5
    }
  }

  break unless parser[:loop]
  sleep parser[:interval].to_i
end
