#
# PostGIS Adapter
#
#
# Code from
# http://georuby.rubyforge.org Spatial Adapter
#

if defined?(Rails) 
  require 'postgis_adapter/railtie'
else
  require 'active_record'
  require 'active_record/connection_adapters/postgresql_adapter'

  require 'postgis_adapter/init'
end
