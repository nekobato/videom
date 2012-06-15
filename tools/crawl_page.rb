#!/usr/bin/env ruby
require File.expand_path 'init', File.dirname(__FILE__)
require 'open-uri'
require 'nokogiri'
require 'uri'
require 'kconv'

parser = ArgsParser.parse ARGV do
  arg :loop, 'do loop', :alias => :l, :default => false
  arg :url, 'URL of page'
  arg :filter, 'download file pattern', :default => '.+\.(mp4|mov|flv|mpe?g|avi)$'
  arg :basic_user, 'basic auth user'
  arg :basic_pass, 'basic auth passwd'
  arg :interval, 'loop interval (sec)', :alias => :i, :default => 600
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param? :url
  puts parser.help
  exit
end

loop do
  http_opt = {}
  if parser.has_param?(:basic_user, :basic_pass)
    http_opt = {
      :http_basic_authentication => [parser[:basic_user], parser[:basic_pass]]
    }
  end
  
  doc = Nokogiri::HTML open(parser[:url], http_opt).read.toutf8
  urls = doc.xpath('//a').to_a.map{|i|
    if URI.parse(i['href']).class == URI::Generic
      res = parser[:url].gsub(/\/$/, '') + '/' + i['href']
    else
      res = i['href']
    end
    res
  }.delete_if{|i|
    !(i =~ Regexp.new(parser[:filter]))
  }
  
  urls.each{|u|
    v = {
      :title => URI.decode(u.split(/\//).last),
      :video_url => u,
      :crawl_at => Time.now.to_i,
      :url => parser[:url],
      :http_opt => { :user => parser[:basic_user].to_s, :pass => parser[:basic_pass].to_s }
    }
    puts v[:title] + ' - ' + v[:url]
    next if Video.where(:video_url => u).count > 0
    puts ' => saved!' if Video.new(v).save
  }

  break unless parser[:loop]
  sleep parser[:interval].to_i
end
