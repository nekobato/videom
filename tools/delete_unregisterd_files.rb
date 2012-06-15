#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# DBに登録されていないファイルを削除する
require File.expand_path 'init', File.dirname(__FILE__)

Dir.glob("#{@@dir}/*").each{|f|
  fname = f.split(/\//).last
  begin
  if Video.where(:file => fname).count < 1
    puts "delete #{fname}"
    File.delete f
  end
  rescue => e
    STDERR.puts e
  end
}
