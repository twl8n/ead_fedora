
EAD finding aid to Fedora Commons repository objects.

Table of contents
-----------------
License and credits
Introduction



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
standard EAD finding aid, and creates Fedora objects for he collection
and all c0x container elements. Enhancements will include creating
objects for the digital files. This will happen via an external
utility if such a utility can be found. 



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

You might have change the shebang of the .rb scripts.




Requirements
------------

You may have to install gems: rest-client, nokogiri. I suppose that
gem "erb" is standard since that is the Rails template engine.

You'll need hydra-jetty, or Fedora Commons and Tomcat. See notes below.




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

http://localhost:8983/fedora/


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

x system description for successful install of hydra-jetty aug 2011

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
can test with a few items, but getting pids for 330 Fedora object and
ingesting 330 foxml objects causes an exception.

