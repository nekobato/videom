#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'irb'

require File.expand_path '../bootstrap', File.dirname(__FILE__)
Bootstrap.init :inits, :models, :libs

IRB.start
