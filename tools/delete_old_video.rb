#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/init'

videos = Video.where(:file => /.+/, :video_url => /^http.+/).asc(:_id)

puts "#{videos.count} videos in queue"

videos.each{|v|
  puts "#{v.title} - #{v.url}"
  puts "  delete? [Y/n]"
  if gets !~ /n/i
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
