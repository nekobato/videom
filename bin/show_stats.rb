#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'pp'

[:inits, :models].each do |cat|
  Dir.glob("#{File.dirname(__FILE__)}/../#{cat}/*.rb").each do |rb|
    puts "load #{rb}"
    require rb
  end
end

pp Video.stats
