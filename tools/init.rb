$stdout.sync = true

require 'rubygems'
require 'bundler/setup'
require 'FileUtils'
require 'args_parser'
require 'digest/md5'
require 'mini_exiftool'
require 'curb'
require File.expand_path '../bootstrap', File.dirname(__FILE__)

Bootstrap.init :inits, :libs, :models

begin
  @@dir = File.expand_path "../#{Conf['video_dir']}", File.dirname(__FILE__)
  FileUtils.mkdir_p(@@dir) unless File.exists? @@dir
  @@thumb_dir = File.expand_path "../#{Conf['thumb_dir']}", File.dirname(__FILE__)
  FileUtils.mkdir_p(@@thumb_dir) unless File.exists? @@thumb_dir
rescue => e
  STDERR.puts e
  exit 1
end

