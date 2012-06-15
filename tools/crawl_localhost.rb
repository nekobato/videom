#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :path, 'directory path'
  arg :filter, 'download file pattern', :default => '.+\.(mp4|mov|flv|mpe?g|avi)$'
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 600
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param? :path
  puts parser.help
  exit
end

parser[:path] = parser[:path].gsub(/\/$/,'')

filter = /#{parser[:filter]}/i

loop do
  files = Dir.glob("#{parser[:path]}/*").delete_if{|i|
    !(i =~ filter)
  }
  
  files.each do |file|
    next if Video.where(:video_url => file).count > 0
    begin
      exif = MiniExiftool.new file
      raise "#{exif['mime_type']} is not video file" unless exif['mime_type'] =~ /^video\/.+$/i
      fname = Digest::MD5.hexdigest(file)
      FileUtils.copy(file, "#{@@dir}/#{fname}")
    rescue => e
      STDERR.puts e
      next
    end
    v = {
      :file => fname,
      :title => "uploaded at #{File.mtime(file)}",
      :video_url => file,
      :url => File.dirname(file),
      :crawl_at => Time.now.to_i,
      :download_at => Time.now.to_i
    }
    puts "#{v.video_url}"
    puts " => saevd!" if Video.new(v).save
  end
  
  break unless parser[:loop]
  sleep parser[:interval].to_i
end
