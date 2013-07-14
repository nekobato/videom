#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :interval,'loop interval (sec)', :alias => :i, :default => 5
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help
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
      unless exif['mime_type'].to_s =~ /^video\/.+/i or exif['MIMEType'].to_s =~ /^video\/.+/i
        raise "#{exif['mime_type']} is not video file"
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
  break unless parser[:loop]
  sleep parser[:interval].to_i
end


