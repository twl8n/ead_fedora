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
require 'erb'

module Ead_fc

class Fx_maker

  # This class can have all the action in initialize() then exit.
  # Name the calling code "run.rb" which should be pretty obvious.

  attr_reader :pid

  def initialize(fname)
    # read the EAD
    # pull info from collection, make foxml
    # Use a foxml erb template
    # foreach container, pull info, make foxml
    # ingest each foxml into Fedora via rest.
    
    # agn_ for agnostic_ which is a generic name of some data field.
    
    # ef_ is for ead_fedora system technical data

    @fname = fname
    @base_url = "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora"
    generic_t_file = "/usr/local/projects/ead_fedora/generic.foxml.xml.erb"
    @xml = Nokogiri::XML(open(@fname))

    # Someone should explain each of the args.
    generic_template = ERB.new(File.new(generic_t_file).read, nil, "%")

    @pid_namespace = "eadfc"
    @ef_create_date = todays_date()

    # collection/container list of hash. Data for each foxml object is
    # in one of the array elements, and each element is a hash.

    @cn_loh = []

    # A new hash. We'll push this onto @cn_loh.
    
    # First a singular bit of code for the collection, then below is a
    # loop for each container.

    rh = Hash.new()

    rh{'pid'} = gen_pid()
    rh{'ef_create_date'} = @ef_create_date
    rh{'is_container'} = false
    rh{'type_of_resource'} = 'collection="yes"'

    # Ruby objects are always passed by reference? This should update
    # rh as a side effect.

    collection_parse(rh)

    # Since we are using instance vars which are essentially global,
    # we might not need binding() which passes the current execution
    # heap space.
    
    @xml_out = generic_template.result(binding())
    ingest_internal()
    write_foxml(rh['pid'])
    @cn_loh.push(rh)

    # Process the container elements, parse, create foxml, ingest, write to file.

    nset = @xml.xpath("//*/xmlns:archdesc/xmlns:dsc")
    container_parse(nset)

  end # initialize

  def container_parse(nset)

    # Modify @cn_loh.
    
    rh = Hash.new()

    # If we aren't using the index xx, remove it.

    nset.children.each_with_index { |ele,xx|
      if ele.name.match(/^c\d+/)

        # Actions to implment here: Get Fedora PID. Get parent PID
        # from the stack. Save current node info in a hash, push onto
        # the container stack, generate foxml, ingest.

        rh['pid'] = gen_pid()
        rh['ef_create_date'] = @ef_create_date
        rh['is_container'] = true
        rh['type_of_resource'] = 'container="yes"'
        rh['parent_pid'] =  @cn_loh.last['pid']

        # container id (attr), container level (attr),
        # container (element, c01, c02, ...), unittitle, container
        # type (attr), container (value, string, could be "6-7"), may be
        # multiple <container> elements), unitdate, scopecontent

        # container_element
        rh['container_element'] = ele.name
        rh['container_level'] = ele.attribute('level')
        rh['container_id'] = ele.attribute('id')

        # Note: container_type and container_value need to be a list
        # of hash due to possible multiple values!
        
        # These seem to work too, returning the expected single value
        # or nil when there isn't a unitdate.

        # nset.xpath("./xmlns:c02/xmlns:c03/xmlns:did").children.xpath("./xmlns:unitdate")[0]

        # nset.xpath("./xmlns:c02/xmlns:c03/xmlns:did")[0].xpath("./xmlns:unitdate")[0]
        
        # Default values.

        rh['container_unitdate'] = ""
        rh['container_unittitle'] = ""

        # <container> element(s) are in a list of hashes.
        rh['ct'] = Array.new()
        nset.xpath("./xmlns:c02/xmlns:c03/xmlns:did")[0].children.each { |child|
          if child.name.match(/container/)
            ch = Hash.new
            ch['container_type'] = child.attribute('type')
            ch['container_value'] = child.content
            rh['ct'].push(ch)
          end
          
          if child.name.match(/unitdate/)
            rh['container_unitdate'] = child.content
          end
          
          if child.name.match(/unittitle/)
            rh['container_unittitle'] = child.content
          end
        }

        # Get the scopecontent of the current c01 node. If it is not
        # nil look at the children and pull content out of any p
        # elements. Remember that (at least in the nokogiri universe)
        # there are invisible text elements around all other elements.

        if ele.name.match(/c01/)
          scon = ele.xpath("./xmlns:scopecontent")[0]
          if scon.class.to_s.match(/nil/i)
            # When nil do nothing.
          else
            if scon.name.match(/scopecontent/)
              tween = ""
              scon.children.each { |pp|
                if pp.name.match(/p/)
                  rh['scopecontent'].concat("#{tween}#{pp.content.strip.chomp}")
                  tween = "\n\n"
                end
              }
            end
          end
        end

        # collection info

        rh['titleproper'] = @xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content
        rh['title'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unittitle")[0].content
        rh['creator'] = @xml.xpath("//*/xmlns:origination[@label='Creator:']/xmlns:persname")[0].content
        
        rh['id'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitid")[0].content

        tween = ""
        rh['scope'] = ""
        @xml.xpath("//*/xmlns:archdesc/xmlns:scopecontent/xmlns:p").each { |ele|
          rh['scope'] += "#{tween}#{ele.content}"
          tween = "\n\n"
        }
        
        tween = ""
        rh['corp_name'] = ""
        @xml.xpath("//*/xmlns:publicationstmt/xmlns:publisher").each { |ele|
          rh['corp_name'] += "#{tween}#{ele.content}"
          tween = ", "
        }
        rh['create_date'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitdate")[0].content
        
        rh['extent'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent")[0].content
        
        rh['abstract'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:abstract")[0].content
        tween = ""
        rh['bio'] = ""
        @xml.xpath("//*/xmlns:archdesc/xmlns:bioghist/xmlns:p").each { |ele|
          rh['bio'] += "#{tween}#{ele.content}"
          tween = "\n\n"
        }
        
        tween = ""
        rh['acq_info'] = ""
        @xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:descgrp/xmlns:acqinfo/xmlns:p").each { |ele|
          rh['acq_info'] += "#{tween}#{ele.content}"
          tween = "\n\n"
        }
        
        tween = ""
        rh['cite'] = ""
        @xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:prefercite/xmlns:p").each { |ele|
          rh['cite'] += "#{tween}#{ele.content.strip}"
          tween = "\n\n"
        }

        rh['type'] = @xml.xpath("//*/xmlns:archdesc")[0].attributes['level']
        
        if (rh['type'] == "collection")
          rh['object_type'] = "set"
          rh['set_type'] = rh['type']
        end
        
        rh['agreement_id'] = ""
        rh['project'] = rh['title']
        
        
        @xml_out = generic_template.result(binding())
        ingest_internal()
        write_foxml(rh['pid'])

        result = container_parse(ele)

        # Actions to implment here: Pop stack. When we eventually
        # implement "isParentOf" then this is where we will modify the
        # Fedora object created above to know about all the children
        # created during the recursion.

        @cn_loh.pop()

      end
    }
    return "#{nset.name} #{nset.get_attribute('id')}"
  end


  def collection_parse(rh)
    
    # Not used currently, but could be later.
    ead_schema_ns = 'urn:isbn:1-931666-22-9'
    
    # Agnostic variables. This is OOP so it is ok to use instance vars
    # because they won't cause any of the bugs that arise from using
    # globals in imperative code. Obi wan says: These aren't the
    # globals you're looking for.
    
    rh['titleproper'] = @xml.xpath("//*/xmlns:titleproper[@type='formal']")[0].content
    
    rh['title'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unittitle")[0].content
    
    rh['creator'] = @xml.xpath("//*/xmlns:origination[@label='Creator:']/xmlns:persname")[0].content
    
    rh['id'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitid")[0].content
    
    # Ignore <head>. Get all <p> and separate by \n -->
    
    # Tween always at the beginning. Start with "" and change to the
    # tween string after the first iteration. No knowing what this
    # text will be used for, separate paragraphs with a double
    # newline. 
    
    tween = ""
    rh['scope'] = ""
    @xml.xpath("//*/xmlns:archdesc/xmlns:scopecontent/xmlns:p").each { |ele|
      rh['scope'] += "#{tween}#{ele.content}"
      tween = "\n\n"
    }
    
    # It is hard to know how other institutions will handle this. In
    # the short term using ", " as the tween looks pretty reasonable.

    tween = ""
    rh['corp_name'] = ""
    @xml.xpath("//*/xmlns:publicationstmt/xmlns:publisher").each { |ele|
      rh['corp_name'] += "#{tween}#{ele.content}"
      tween = ", "
    }
    
    rh['create_date'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:unitdate")[0].content

    rh['extent'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent")[0].content

    rh['abstract'] = @xml.xpath("//*/xmlns:archdesc/xmlns:did/xmlns:abstract")[0].content
    
    # Not including the <head>. Could be multiple <p> so separate with
    # "\n\n". See comments above about tween.

    tween = ""
    rh['bio'] = ""
    @xml.xpath("//*/xmlns:archdesc/xmlns:bioghist/xmlns:p").each { |ele|
      rh['bio'] += "#{tween}#{ele.content}"
      tween = "\n\n"
    }

    tween = ""
    rh['acq_info'] = ""
    @xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:descgrp/xmlns:acqinfo/xmlns:p").each { |ele|
      rh['acq_info'] += "#{tween}#{ele.content}"
      tween = "\n\n"
    }
    
    tween = ""
    rh['cite'] = ""
    @xml.xpath("//*/xmlns:archdesc/xmlns:descgrp/xmlns:prefercite/xmlns:p").each { |ele|
      rh['cite'] += "#{tween}#{ele.content.strip}"
      tween = "\n\n"
    }

    # Used in <mods:identifier type="local">

    # How we know if this is a "collection": <archdesc level="collection"

    # <c01 id="ref11" level="series"> has a
    # <did><unittitle>Inventory</unittitle></did> that could be used
    # to additionally specify the type. Or not.

    # Some containers have a container element that tells us the type,
    # and the box id number. <did><container type="Box">1</container>
    
    rh['type'] = @xml.xpath("//*/xmlns:archdesc")[0].attributes['level']
    
    # Used in foxml identitymetadata <objectId> and <objectType>

    if (rh['type'] == "collection")
      rh['object_type'] = "set"
      rh['set_type'] = rh['type']
    end
    
    rh['agreement_id'] = ""
    rh['project'] = rh['title']
  end # collection_parse
  
  
  def write_foxml(pid)
    fn = pid + ".xml"
    fn.gsub!(/:/,"_")
    File.open(fn, "wb") { |my_xml|
      my_xml.write(@xml_out)
    }
  end


  def ingest_internal

    # Ingest existing @xml_out. 

    wuri = "#{@base_url}/objects/new?format=info:fedora/fedora-system:FOXML-1.1"
    payload = RestClient::Payload.generate(@xml_out)

    # Do not call to_s() on payload because payload is a stream object
    # and to_s() doesn't reset the stream byte counter which
    # essentially means the stream becomes empty.

    if true
      deb = payload.inspect()
      print "working uri: #{wuri}\nvar: #{deb[0,10]}\n...\n#{deb[-80,80]}\n"
      ingest_result_xml = RestClient.post(wuri,
                                          payload,
                                          :content_type => "text/xml")
      return ingest_result_xml
    else
      var = payload
      print "working uri: #{wuri}\nvar: #{payload.to_s[0,10]}\n again: #{var}more stuff\n"
      return ""
    end
  end

  def xml_out
    return @xml_out
  end

  def todays_date
    # Example: 2011-07-18T12:34:56.789Z

    # Use GMT time, but hard code the Z since Ruby %Z says "GMT" and
    # Fedora may be expecting a Z (military time zone for UTC).

    # Ruby 1.8.7 strftime() doesn't grok %L, so hard code that as '.000'.

    return Time.now.utc.strftime("%Y-%m-%dT%T.000Z")
  end

def gen_pid

    # If we use a "format" param in the URL, then the returned object
    # is of the expected type. If not, it is probably necessary to
    # include a :content_type hash key-value as the third arg to
    # post().

    working_url = "#{@base_url}/objects/nextPID?namespace=#{@pid_namespace}&format=xml"
    some_xml = RestClient.post(working_url, '')
    numeric_pid = some_xml.match(/<pid>#{@pid_namespace}:(\d+)<\/pid>/)[1]

    # Fedora requires pids to match a regex, apparently text:number

    return "#{@pid_namespace}:#{numeric_pid}"
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
