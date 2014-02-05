Gem::Specification.new do |spec|
  spec.name     = 'dr-postgis_adapter'
  spec.version  = '0.8.3'
  spec.authors  = ['Marcos Piccinini', 'Luc Donnet', 'Marc Florisson']
  spec.summary  = 'PostGIS Adapter for Active Record'
  spec.email    = 'x@nofxx.com, luc.donnet@free.fr, mflorisson@gmail.com'
  spec.homepage = 'http://github.com/dryade/postgis_adapter'

  spec.rdoc_options = ['--charset=UTF-8']
  spec.rubyforge_project = 'postgis_adapter'

  spec.files = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.test_files = Dir['spec/**/*.rb']
  spec.extra_rdoc_files  = ['README.rdoc']

  spec.add_dependency 'nofxx-georuby'
  spec.add_dependency 'rake'

  spec.description = 'Execute PostGIS functions on Active Record'
end
