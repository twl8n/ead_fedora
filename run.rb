#!/bin/env ruby

require 'ead_fc'

fxm = Ead_fc::Fx_maker.new("/home/twl8n/ead_fedora/tobin_mssa.ms.1746.bpg.xml")
# puts fxm.xml_out()

# print "Ingest result: #{fxm.ingest_internal()}\n"
