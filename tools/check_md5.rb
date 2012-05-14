#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/init'

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 5
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help
  puts parser.help
  exit
end

loop do
  videos = Video.find_queue_checkmd5
  puts "#{videos.count} files in queue"
  videos.each do |v|
    file = "#{@@dir}/#{v.file}"
    puts "#{v.title} - #{file}"
    begin
      unless File.exists? file
        v.hide = true
        v.file = nil
      else
        md5 = Digest::MD5.hexdigest(open(file).read)
        puts " => #{md5}"
        v.md5 = md5
        if Video.where(:md5 => md5).count > 0
          puts "#{md5} is already stored"
          File.delete file if File.exists? file
          v.hide = true
          v.file = nil
          puts 'deleted!!'
        end
      end
      v.save
    rescue => e
      STDERR.puts e
    next
    end
  end
  break unless parser[:loop]
  sleep parser[:interval].to_i
end


