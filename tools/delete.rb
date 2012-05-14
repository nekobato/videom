#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/init'

videos = Video.where(:file => /.+/, :video_url => /^http.+/)

puts "#{videos.count} videos in queue"

videos.each{|v|
  puts "#{v.title} - #{v.url}"
  puts "  delete? [y/N]"
  if gets =~ /y/i
    begin
      fname = "#{@@dir}/#{v.file}"
      v.delete_file!
      puts " => #{fname} deleted"
    rescue => e
      STDERR.puts e
    end
  else
  end
}
