#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'kconv'

class Himado

  class Error < Exception
  end

  def initialize(user_agent=nil)
  end

  def videos(params={:sort => 'movie_id'})
    url = "http://himado.in/"
    url += '?' + params.map{|k,v|
      "#{k}=#{URI.encode v.to_s}"
    }.join('&')
    doc = Nokogiri::HTML open(url).read.toutf8
    doc.xpath('//a').to_a.delete_if{|a|
      !(a['href'] =~ /^http:\/\/himado\.in\/\d+$/) or !a['title']
    }.map{|a|
      {
        :url => a['href'],
        :title => a['title']
      }
    }.uniq
  end

  def videos_page(page, params)
    (0...page).to_a.map{|i|
      params[:page] = i
      videos(params)
    }.flatten.uniq
  end

  def video(url)
    res = Hash.new
    doc = Nokogiri::HTML open(url).read.toutf8
    scripts = doc.xpath('//script').to_a.map{|i|
      i.text
    }.join('').split(';')
    
    begin
      res[:video_urls] = scripts.detect{|i| i =~ /var ary_spare_sources/}.scan(/http[^\"\']+/).map{|i| URI.decode i}
    rescue => e
      STDERR.puts e
      STDERR.puts '!!spare videos not found.'
      res[:video_urls] = Array.new
    end
    begin
      res[:video_urls] << scripts.delete_if{|i|
        !(i =~ /var +display_movie_url += +/)
      }.map{|i|
        URI.decode i.scan(/http[^\"\']+/).first
      }.first
    rescue => e
      STDERR.puts e
      STDERR.puts '!!video_urls[0] not detected'
    end

    res[:title] = doc.xpath('//h1[@id="movie_title"]').first.text
    res[:url] = url
    res[:page_id] = url.scan(/\/(\d+)$/).first.first.to_i
    res[:tags] = doc.xpath('//a').map{|a|
      begin
        tag = URI.decode a['href'].scan(/\?keyword=(.+)$/).first.first
      rescue
        tag = nil
      end
      tag
    }.delete_if{|tag| tag == nil }
    return res
  end
end

if $0 == __FILE__
  himado = Himado.new
  # p videos = himado.videos({:keyword => 'Steins;Gate'})
  p videos = himado.videos
  videos[0...10].each do |v|
    p himado.video(v[:url])
  end
  #p himado.video(videos[2][:url])
end
