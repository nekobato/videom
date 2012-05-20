#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'irb'

require File.dirname(__FILE__)+'/../bootstrap'
Bootstrap.init :inits, :models, :libs

IRB.start
