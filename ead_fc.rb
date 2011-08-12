#!/usr/bin/ruby 

# Copyright 2011 University of Virginia
# Created by Tom Laudeman

# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.

require 'rubygems'
require 'rest-client'

module Ead_fc

class Fx_maker

  # This class can have all the action in initialize() then exit.
  # Name the calling code "run.rb" which should be pretty obvious.

  def initialize
    # read the EAD
    # pull info from collection, make foxml
    # Use a foxml erb template
    # foreach container, pull info, make foxml
    # ingest each foxml into Fedora via rest.
    
    # agn_ for agnostic_ which is a generic name of some data field.
    
    # ef_ is for ead_fedora system technical data

    @base_url = "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora"
    @pid_namespace = "ead_fc"

  end


  def gen_pid

    # If we use a "format" param in the URL, then the returned object
    # is of the expected type. If not, it is probably necessary to
    # include a :content_type hash key-value as the third arg to
    # post().

    working_url = "#{@base_url}/objects/nextPID?namespace=#{@pid_namespace}&format=xml"
    some_xml = RestClient.post(working_url, '')

  end

  def ingest(fname)
    
    # Must include the third arg ':content_type => "text/xml"' or we
    # get a 415 Unsupported media type response from the server.

    working_url = "#{@base_url}/objects/new?format=info:fedora/fedora-system:FOXML-1.1"
    some_xml = RestClient.post(working_url,
                               RestClient::Payload.generate(IO.read(fname)),
                               :content_type => "text/xml")
    print some_xml
  end

end

end
