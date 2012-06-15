#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'pp'
require File.expand_path '../bootstrap', File.dirname(__FILE__)
Bootstrap.init :inits, :libs, :models

pp Video.stats
