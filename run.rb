#!/bin/env ruby

require 'ead_fc'

# unbuffer output.
STDOUT.sync = true

fxm = Ead_fc::Fx_maker.new("tobin_mssa.ms.1746.bpg.xml")

