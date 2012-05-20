require 'rubygems'
require 'bundler/setup'
require 'FileUtils'
require 'args_parser'
require 'digest/md5'
require 'mini_exiftool'
require 'curb'
require File.dirname(__FILE__)+'/../bootstrap'

Bootstrap.init :inits, :models, :libs

begin
  @@dir = File.dirname(__FILE__)+'/../'+Conf['video_dir']
  FileUtils.mkdir_p(@@dir) unless File.exists? @@dir
  @@thumb_dir = File.dirname(__FILE__)+'/../'+Conf['thumb_dir']
  FileUtils.mkdir_p(@@thumb_dir) unless File.exists? @@thumb_dir
rescue => e
  STDERR.puts e
  exit 1
end
