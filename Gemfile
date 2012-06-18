source "http://rubygems.org"
# Add dependencies required to use your gem here.

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', :git => 'git://github.com/dryade/activerecord-jdbc-adapter.git'
  gem 'jruby-openssl'
end

platforms :ruby do    
  gem 'pg', '~> 0.11.0' 
end

gem "nofxx-georuby"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", "~> 2.3.0"
  gem "bundler", "~> 1.1.3"
  gem "rcov", ">= 0"
  gem "autotest"
end
