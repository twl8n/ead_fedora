
# Constants for ead_fc.rb

# Copy this file to config.rb, and edit as necessary.

# URL for the rest api. Include userid:password as necessary.

Base_url = "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora"

# Full path to the foxml  and contentmeta erb templates.

Generic_t_file = "/usr/local/projects/ead_fedora/generic.foxml.xml.erb"
Contentmeta_t_file = "/usr/local/projects/ead_fedora/contentmeta.xml.erb"

# A namespace for your Fedora pids. Like 'demo' where a pids is
# demo:1. Spaces and underscores not allowed.

Pid_namespace = "eadfc"

# Document root for web services for a given collection.

Content_url = "http://tull.lib.virginia.edu/mssa.ms.1746"

# Right now this is simply a path. The files are relative to this
# path.  Example relative path:
# data/2004-M-088.0007/2004-M-088.0007.txt

Content_home = "/var/www/html/mssa.ms.1746"

# A printf format string. Since we have a Bagit bag, the files are in
# a data directory. I guess this will always be the same relative to
# Content_home, so maybe this const is redundant.

Content_path = "/var/www/html/mssa.ms.1746/data/%s"
