module PostgisAdapter
  class Railtie < Rails::Railtie
    initializer "postgis_adapter", :after => "active_record.initialize_database" do
      require 'postgis_adapter/init'
    end
  end
end
