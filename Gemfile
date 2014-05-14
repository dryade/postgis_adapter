source "http://rubygems.org"

# Specify your gem's dependencies in postgis_adapter.gemspec
gemspec

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'jruby-openssl'
end

platforms :ruby do    
  gem 'pg', '~> 0.11.0' 
end

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", "~> 2.3.0"
  gem "rcov", ">= 0"
  gem "autotest"
end
