#!/bin/env ruby

require 'ead_fc'

# unbuffer output.
STDOUT.sync = true

# ead xml file string, debug boolean

myfile = ARGV[0]

require myfile

if ARGV.size == 0
  print "Usage: #{$0} collction_config_file.rb\n"
  exit
end

if File.exists?(Ead_file)
  fxm = Ead_fc::Fx_maker.new(Ead_file, Fx_debug)
else
  print "Can't find file #{Ead_file}\n"
  exit
end
