#!/bin/env ruby

require 'ead_fc'

fxm = Ead_fc::Fx_maker.new("/home/twl8n/ead_fedora/tobin_mssa.ms.1746.bpg.xml")
# puts fxm.xml_out()


if true
  fn = fxm.pid + ".xml"
  fn.gsub!(/:/,"_")
  File.open(fn, "wb") { |my_xml|
    my_xml.write(fxm.xml_out())
  }
  print "Wrote: #{fn}\n"
end

print "Ingest result: #{fxm.ingest_internal()}\n"
