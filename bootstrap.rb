require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra/reloader' if development?
require 'yaml'
require 'json'
require 'haml'

[:inits, :helpers, :models ,:controllers].each do |dir|
  Dir.glob(File.dirname(__FILE__)+"/#{dir}/*.rb").sort.each do |rb|
    puts "loading #{rb}"
    require rb
  end
end

Conf['dir'] = File.dirname(__FILE__)+'/'+Conf['video_dir']
Conf['thumb_dir'] = File.dirname(__FILE__)+'/'+Conf['thumb_dir']


set :haml, :escape_html => true
