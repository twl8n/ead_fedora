
Convert EAD finding aid to Fedora Commons repository objects.

Table of contents
-----------------
Updates
License and credits
Introduction
Input and output
Collection digital assets
Configuration
Requirements
How to run with Fedora Commons plus Tomcat
How to run with hydra-jetty

Updates
-------


*_config.rb is collection specific. See hull_config.rb

*_tech_data.db is a SQLite database of technical metadata for
 files. Each db is collection specific. If the file exists it will be
 used. If it does not exist, it will be created which can take a few
 seconds.

The old, original code that ingested and (attempted) to update the
Solr index is ead_fc_solr.rb. The old versions of ead_fc.rb are in git
as well, but I wanted a static file that was the end of the old way of
doing things.



License and credits
-------------------

Created by Tom Laudeman

All files of this package are Copyright 2011 University of Virginia

All files of this package are licensed under the Apache License.
Licensed under the Apache License Version 2.0 (the "License"); you may
not use these files except in compliance with the License.  You may
obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.



Introduction
------------

This project is a small Ruby utility (Module, Class, API) that reads a
standard EAD finding aid, and creates Fedora objects for the collection
and all c0x container elements. Enhancements will include creating
objects for the digital files. 



Input and output
----------------

Sample files can be found at github, and you can view the files online
or you can clone the github repository. When viewing github files in
your browser, line numbers are displayed on the left.

https://github.com/twl8n/ead_fedora

The sample input EAD file is tobin_mssa.ms.1746.bpg.xml. Sample output
files are demo*.xml. Templates for the output are *.erb.

The conversion (crosswalk) code is in ead_fc.rb methods
collection_parse() and container_parse(). You should be able to read
the input, look at the conversion code, look at the *.erb templates,
look at the output and be able to trace data from the input, through
the code, into the template, and finally see the data in the sample
output files. A complete understanding of then crosswalk requires all
4 files, however, certain tasks only require you to look at one or two
files.

For example, the Tobin collection unittitle is around line 55 in
"tobin_mssa.ms.1746.bpg.xml":

<archdesc level="collection" relatedencoding="MARC21" type="register">
  <did>
    <unittitle label="Title:">James Tobin papers</unittitle>

The Ruby script ead_fc.rb at approximately line 450 has an Xpath query
corresponding to the XML elements above, and assigns the value of
<unittitle> to a hash key 'title':

rh['title'] = @xml.xpath("//*/#{@ns}archdesc/#{@ns}did/#{@ns}unittitle")[0].content

Note that the Ruby method beginning with "def collection_parse(hr)" around
line 430 has many Xpath queries each of which reads data from the EAD.

The template file "generic.foxml.xml.erb" at line 33 has the following
DC metadata that references the same hash key "rh['title']":

<dc:title><%= rh['title'] %></dc:title>

Finally, the collection level foxml "demo_hypatia_70.xml" has the dc metadata line:

<dc:title>James Tobin papers</dc:title>

All of the EAD-to-Fedora data crosswalks work this way, although some
have conditional (if) statements in either the Ruby code or in the
.erb template (or both). Some data elements also occur as multiple
values and therefore may require a loop in the Ruby code and the .erb
template.


Collection digital assets
-------------------------


If a collection has file associated with it, then those files need to
be manually downloaded and stored locally.

See the config.rb variable Digital_assets_home.

run.rb (via class Fx_maker in ead_fc.rb) will attempt to locate files
that correspond to EAD <c0x> or <c> containers. Current code
understands the organization of files for Yale and Hull.

The file system is traversed by Fx_file_info, and the path/file from
the EAD is tested against the known paths. The test is either full
equivalence or via a regular expression. Ideally, the test will be a
regular expression determined by the config file. 





Configuration
-------------

Copy config.dist.rb to config.rb. Edit to have values appropriate for
your environment.

Base_url is your Fedora REST API-M URL. 

Generic_t_file is the full path to the file
"generic.foxml.xml.erb". Long term the software may assume this is in
the same directory as the Ruby scripts, but for now just put in the
full path.

Pid_namespace is a string that is the Fedora PID prefix. No spaces or
underscores. Eventually is might be nice to make this a command line
option.

You might have change the shebang #! line of the .rb scripts.




Requirements
------------

You may have to install gems: rest-client, nokogiri. I suppose that
gem "erb" is standard since that is the Rails template engine.

You'll need hydra-jetty, or Fedora Commons and Tomcat. See notes below.


> which gem
~/.rvm/rubies/ruby-1.8.7-head/bin/gem

> which ruby                            
~/.rvm/rubies/ruby-1.8.7-head/bin/ruby

gem install rest-client -v 1.6.3 --no-rdoc --no-ri
gem install nokogiri --no-rdoc --no-ri
gem install active-fedora --no-rdoc --no-ri
gem install solrizer-fedora --no-rdoc --no-ri
gem install ruby-debug --no-rdoc --no-ri

> gem list

*** LOCAL GEMS ***

active-fedora (3.0.3)
activemodel (3.0.10)
activeresource (3.0.10)
activesupport (3.0.10)
builder (2.1.2)
columnize (0.3.4)
daemons (1.1.4)
equivalent-xml (0.2.7)
facets (2.9.2)
fastercsv (1.5.4)
i18n (0.5.0)
linecache (0.46)
mediashelf-loggable (0.4.7)
mime-types (1.16)
multipart-post (1.1.2)
nokogiri (1.5.0)
om (1.4.0)
rake (0.8.7)
rbx-require-relative (0.0.5)
rdoc (2.5.9)
rest-client (1.6.3)
rsolr (1.0.2)
ruby-debug (0.10.4)
ruby-debug-base (0.10.4)
solr-ruby (0.0.8)
solrizer (1.1.0)
solrizer-fedora (1.1.1)
stomp (1.1.9)
xml-simple (1.1.0)


# If you are using active-fedora 2.2.2, you must use the combined
# fedora/solr config:

cp fedora_solr_dist.yml fedora.yml
emacs fedora.yml config.rb

# If you are using active-fedora 3.x.x or newer you should use the
# separate fedora and solr config files

cp fedora_dist.yml fedora.yml
cp solr_dist.yml solr.yml
emacs fedora.yml solr.yml config.rb

# For unknown reasons, the "environment" env variable isn't set after
# running "rvm gemset use foo", so put the env var on the command
# line.

environment=development run.rb tobin_mssa.ms.1746.bpg.xml



Handy rvm commands:

rvm list
rvm gemset create foo
rvm gemset use foo
rvm gemset name
# return to default gemset
rvm gemset use 
rvm use ruby-1.8.7-head




How to run with Fedora Commons plus Tomcat
------------------------------------------

I recommend this option. It has more steps than hydra-jetty, but the
resulting install seems more robust. Install FC and Tomcat
instructions found in the ead_fedora github repo.

You must have Flash to use the admin interface. You can use the admin
"Ingest Object" feature to create a Fedora object from foxml (or one
of several other formats).

With the FC+Tomcat server running, visit this URL (change localhost to
your host name as necessary):

http://localhost:8080/fedora/

Note that Tomcat's default port is 8080. (Jetty's default port is 8983).

The URL below is a quick run through with shell commands and brief
comments. Great for experienced developers when nothing goes wrong:

https://github.com/twl8n/ead_fedora/blob/master/fcrepo_quick_install.txt

The URL below is the full instructions with extensive notes and some
session transcripts, error info, and debugging suggestions:

https://github.com/twl8n/ead_fedora/blob/master/fcrepo_install.txt





How to run with hydra-jetty
---------------------------

This option is quick, and works for a small number of transactions,
but it threw and exception and stopped working when I ingested 335
foxml objects.

I did my install of hydra-jetty in /usr/local/projects Installed on
Fedora Linux 12, x86_64, java version "1.6.0_20", rvm 0.1.42, ruby
1.8.7. These notes assume that you are running a Linux desktop, or
running X11 via forwarding. You may have to change "localhost" to the
correct hostname, and you may have to change firewall settings to
allow traffic on port 8983, or you may have to change the jetty port.

cd /usr/local/projects
git clone https://github.com/projecthydra/hydra-jetty.git
java -jar start.jar

# Session transcript below. Wait for the "Started SocketConnector ..." line.

> java -jar start.jar
2011-08-09 16:28:54.635::INFO:  Logging to STDERR via org.mortbay.log.StdErrLog
2011-08-09 16:28:54.898::INFO:  jetty-6.1.3
...
2011-08-09 16:29:41.189::INFO:  Started SocketConnector @ 0.0.0.0:8983


In another terminal window (or from the desktop if your desktop is the
server) run a web browser in the background. If the web browser is
running on the same machine as jetty, then visit this URL:

http://localhost:8983/fedora/

If you see java exceptions, kill java process and start again. The
second time around everything worked for me.

You can also change the port jetty starts on by editing the file
etc/jetty.xml and changing this line to indicate a different port
number:

<Set name="port"><SystemProperty name="jetty.port" default="8983"/></Set>

To see all your Fedora object, search all fields from phrase "*:*"
using the objects URL below. If you need a userid and password for any
features, it defaults to fedoraAdmin and fedoraAdmin.

http://localhost:8983/fedora/objects

You must have Flash to use the admin interface. You can use the admin
"Ingest Object" feature to create a Fedora object from foxml (or one
of several other formats).

http://localhost:8983/fedora/admin

The objects page returned http 500 java.lang.OutOfMemoryError: PermGen space

http://localhost:8983/fedora/objects

log info comes out at the console (termina) and at:

/usr/local/projects/hydra-jetty/fedora/default/server/logs/fedora.log

System description for successful install of hydra-jetty aug 2011:

> lsb_release -a
LSB Version:    :core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
Distributor ID: Fedora
Description:    Fedora release 12 (Constantine)
Release:        12
Codename:       Constantine

> uname -a
Linux tull.lib.virginia.edu 2.6.32.26-175.fc12.x86_64 #1 SMP Wed Dec 1 21:39:34 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux

> which java
/usr/bin/java

> java -version
java version "1.6.0_20"
Java(TM) SE Runtime Environment (build 1.6.0_20-b02)
Java HotSpot(TM) 64-Bit Server VM (build 16.3-b01, mixed mode)

> rvm --version
rvm 0.1.42 by Wayne E. Seguin (wayneeseguin@gmail.com) [http://rvm.beginrescueend.com/]

> ruby --version
ruby 1.8.7 (2010-07-17 patchlevel 300) [x86_64-linux]

> which ruby
~/.rvm/rubies/ruby-1.8.7-head/bin/ruby

Note that something runs out of PermGen memory, probably jetty. You
can test with a few items, but getting pids for 330 Fedora objects and
ingesting 330 Fedora objects as foxml causes an exception.




Technical metadata notes
------------------------


See files_datastream.xml.erb. 

<contentMetadata> attr objectId = could be the bagit uuid. Stanford uses a druid.

<resource> attr id = unk
attr type = unk
attr objectId = uuid?

<file> id = from manifest-md5.txt or file.xml <source><image_filename> although they won't always be disk images and the file.xml is generated by "fiwalk". Probably should require some additional technical meta data in the bag ala Rubymatica.

attr format = unk, does this have a controlled vocabulary?
attr mimetime = should come from the (nonexistant) Rubymatica meta data

<location type="url"> = determined by crawling the file system, or Rubymatica metadata
<checksum type="md5"> = determined by crawling the file system, or Rubymatica metadata
<checksum type="sha1"> = determined by crawling the file system, or Rubymatica metadata

