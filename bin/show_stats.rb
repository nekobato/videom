#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'pp'
require File.dirname(__FILE__)+'/../bootstrap'
Bootstrap.init :inits, :models

pp Video.stats
