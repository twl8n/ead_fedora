#!/bin/env ruby

require 'ead_fc'

# unbuffer output.
STDOUT.sync = true

# ead xml file string, debug boolean

myfile = ARGV[0]

if ARGV.size == 0
  print "Usage: #{$0} ead_file.xml\n"
  exit
end

debug = true # true or false

if File.exists?(myfile)
  fxm = Ead_fc::Fx_maker.new(myfile, debug)
else
  print "Can't find file #{myfile}\n"
  exit
end
