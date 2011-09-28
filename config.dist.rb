# Constants for run.rb

# Copy this file to foo_config.rb where "foo" is the collection name,
# and edit as necessary.

Schema_sql = "/usr/local/projects/ead_fedora/schema.sql"

# Debug mode. 

Fx_debug = true # true or false

# Full path to the EAD file that you want to parse.

Ead_file = "/home/twl8n/ead_fedora/gallagher_u_dga_export_sep_14_2011.xml"

# URL for the rest api. Include userid:password as necessary.

Base_url = "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora"

# Full path to the foxml  and contentmeta erb templates.

Generic_t_file = "/usr/local/projects/ead_fedora/generic.foxml.xml.erb"
Contentmeta_t_file = "/usr/local/projects/ead_fedora/contentmeta.xml.erb"

# A namespace for your Fedora pids. Like 'demo' where a pid is
# demo:1. Spaces and underscores not allowed.

Pid_namespace = "hypatia"

# Currently, there are two of these 'tobin', and 'hull'. They
# determine which hardcoded algorithm is used to determine file paths
# for digital assets in the collection.

Path_key_name = 'hull'

# Document root for web services for a given collection.

Digital_assets_url = "http://aims.lib.virginia.edu/test"

# Right now this is simply a path. The files are relative to this
# path. This might change to a regular expression. Example relative
# path: data/2004-M-088.0007/2004-M-088.0007.txt

Digital_assets_home = "/var/www/html/gallagher/Stephen Gallagher - refined"

# Digital_assets_home = "/var/www/html/mssa.ms.1746/data/%s"
