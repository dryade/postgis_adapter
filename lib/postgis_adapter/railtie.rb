module PostgisAdapter
  class Railtie < Rails::Railtie
    initializer "postgis_adapter", :after => "active_record.initialize_database" do
      unless defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        require 'active_record/connection_adapters/postgresql_adapter'
      end

      require 'postgis_adapter/init'
    end
  end
end
