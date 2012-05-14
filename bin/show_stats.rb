#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require File.dirname(__FILE__)+'/../libs/himado'

[:inits, :models].each do |cat|
  Dir.glob("#{File.dirname(__FILE__)}/../#{cat}/*.rb").each do |rb|
    puts "load #{rb}"
    require rb
  end
end

puts "available videos : #{Video.find_availables.count}"
puts "download queue : #{Video.find_queue_download.count}"
puts "check md5 queue : #{Video.find_queue_checkmd5.count}"
puts "check exif queue : #{Video.find_queue_checkexif.count}"
puts "make thumbnail queue : #{Video.find_queue_makethumbnail.count}"

