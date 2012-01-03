#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/helper'
require 'digest/md5'
require 'FileUtils'
require 'mini_exiftool'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop', false)
parser.comment(:path, 'directory path')
parser.comment(:filter, 'download file pattern', '.+\.(mp4|mov|flv|mpe?g|avi)$')
parser.bind(:interval, :i, 'loop interval (sec)', 600)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if parser.has_option(:help) or !parser.has_param(:path)
  puts parser.help
  exit
end

params[:path] = params[:path].gsub(/\/$/,'')

filter = /#{params[:filter]}/i

loop do
  files = Dir.glob("#{params[:path]}/*").delete_if{|i|
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
    p v
    puts " => saevd!" if Video.new(v).save
  end
  
  break unless params[:loop]
  sleep params[:interval].to_i
end
