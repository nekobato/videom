#!/usr/bin/env ruby
require 'rubygems'
require File.dirname(__FILE__)+'/helper'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop', false)
parser.bind(:interval, :i, 'loop interval (sec)', 600)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if parser.has_option(:help)
  puts parser.help
  exit
end

himado = Himado.new

loop do
  @@conf['tags'].each{|tag|
    puts "tag : #{tag}"
    begin
      videos = himado.videos(:keyword => tag)
    rescue => e
      STDERR.puts e
      next
    rescue Timeout::Error => e
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

  break unless params[:loop]
  sleep params[:interval].to_i
end
