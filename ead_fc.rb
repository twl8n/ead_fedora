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
require 'nokogiri'

module Ead_fc

class Fx_maker

  # This class can have all the action in initialize() then exit.
  # Name the calling code "run.rb" which should be pretty obvious.

  def initialize(fname)
    # read the EAD
    # pull info from collection, make foxml
    # Use a foxml erb template
    # foreach container, pull info, make foxml
    # ingest each foxml into Fedora via rest.
    
    # agn_ for agnostic_ which is a generic name of some data field.
    
    # ef_ is for ead_fedora system technical data

    @base_url = "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora"
    @pid_namespace = "eadfc"
    @pid = gen_pid()
    @ef_create_date = todays_date()
    
  end

  def todays_date
    # Example: 2011-07-18T12:34:56.789Z

    # Use GMT time, but hard code the Z since Ruby %Z says "GMT" and
    # Fedora may be expecting a Z (military time zone for UTC).

    # Ruby 1.8.7 strftime() doesn't grok %L, so hard code that as '.000'.

    return Time.now.utc.strftime("%Y-%m-%dT%T.000Z")
  end

  def read_and_parse
    xml = Nokogiri::XML(open(@fname))

    # Not used currently, but could be later.
    ead_schema_ns = 'urn:isbn:1-931666-22-9'

    # Agnostic variables. This is oop so it is ok to use instance vars
    # because they won't cause any of the bugs that arise from using
    # globals in imperative code. Obi wan says: These aren't the
    # globals you're looking for.

    @agn_title = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content

    # <!-- <origination label="Creator:"><persname rules="aacr" source="ingest"> -->

    @agn_creator = xml.xpath("//*/xmlns:origination[@label='Creator:']/xmlns:persname")[0].content

    # <!-- unitid, Can identifiers have a space? -->
    @agn_id = xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitid")[0].content

    # <archdesc><scopecontent><p> Ignore <head>. Get all <p> and separate by \n -->

    # Tween always at the beginning. Start with "" and change to the
    # tween string after the first iteration. No knowing what this
    # text will be used for, separate paragraphs with a double
    # newline. 

    tween = ""
    @agn_scope = ""
    xml.xpath("//*/xmlns:archdesc/xmlns:scopecontent/xmlns:p").each { |ele|
      @agn_scope += "#{tween}#{ele.content}"
      tween = "\n\n"
    }

    # <!-- <publisher>Yale University Library</publisher>
    #            <publisher>Manuscripts and Archives</publisher> -->

    # It is hard to know how other institutions will handle this. In
    # the short term using ", " as the tween looks pretty reasonable.

    tween = ""
    @agn_corp_name = ""
    xml.xpath("//*/xmlns:publicationstmt/xmlns:publisher").each { |ele|
      @agn_corp_name += "#{tween}#{ele.content}"
      tween = ", "
    }

    # <!-- <unitdate> -->

    @agn_create_date = xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitdate")[0].content

    @agn_extent = xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent")[0].content

    @agn_abstract = xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:abstract")[0].content
    
    # Not including the <head>. Could be multiple <p> so separate with
    # "\n\n". See comments above about tween.

    tween = ""
    @agn_bio = ""
    xml.xpath("//*/xmlns:archdesc/xmlns:bioghist/xmlns:p").each { |ele|
      @agn_bio += "#{tween}#{ele.content}"
      tween = "\n\n"
    }

    # <!-- <acqinfo> -->

    tween = ""
    @agn_acq_info = ""
    xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:descgrp/xmlns:acqinfo/xmlns:p").each { |ele|
      @agn_acq_info += "#{tween}#{ele.content}"
      tween = "\n\n"
    }

    # <!-- prefercite -->

    tween = ""
    @agn_cite = ""
    xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:prefercite/xmlns:p").each { |ele|
      @agn_cite += "#{tween}#{ele.content.strip}"
      tween = "\n\n"
    }

    # ?
    @agn_type = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content

    @agn_object_type = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content
    @agn_set_type = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content

    @agn_agreement_id = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content
    @agn_project = xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content

  end


  def gen_pid

    # If we use a "format" param in the URL, then the returned object
    # is of the expected type. If not, it is probably necessary to
    # include a :content_type hash key-value as the third arg to
    # post().

    working_url = "#{@base_url}/objects/nextPID?namespace=#{@pid_namespace}&format=xml"
    print "wu: #{working_url}\n"
    some_xml = RestClient.post(working_url, '')
    return some_xml.match(/<pid>#{@pid_namespace}:(\d+)<\/pid>/)[1]
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
