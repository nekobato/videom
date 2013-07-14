#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 5
  video2gif_path = `which video2gif`.strip
  arg :video2gif, 'video2gif command path', :default => video2gif_path.size > 0 ? video2gif_path : nil
  arg :gif_fps, 'gif fps', :default => 1
  arg :video_fps, 'video fps', :default => 0.01
  arg :size, 'size', :default => '160x90'
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param? :video2gif
  puts parser.help
  exit
end

loop do
  videos = Video.find_queue_makethumbnail
  videos.each do |v|
    puts "#{v.title}(id:#{v.id}) - #{videos.count} videos in thumbnail queue"
    file = "#{@@dir}/#{v.file}"
    begin
      raise 'file not exists' unless File.exists? file
      out = "#{@@thumb_dir}/#{v.id}.gif"
      puts cmd = "#{parser[:video2gif]} -i #{file} -o #{out} -video_fps #{parser[:video_fps]} -gif_fps #{parser[:gif_fps]} -size #{parser[:size]}"
      system cmd
      raise 'cannot make thumbnail' unless File.exists? out
      v.thumb_gif = "#{v.id}.gif"
    rescue => e
      STDERR.puts e
      v.thumb_gif = ""
    end
    v.save
  end
  break unless parser[:loop]
  sleep parser[:interval].to_i
end
