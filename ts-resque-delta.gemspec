# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'ts-resque-delta'
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pat Allan', 'Aaron Gibralter', 'Danny Hawkins', 'Grzegorz Derebecki']
  s.email       = ['danny.hawkins@gmail.com', 'pat@freelancing-gods.com', 'grzegorz.derebecki@fdb.pl']
  s.homepage    = 'https://github.com/madmax/ts-resque-delta'
  s.summary     = %q{Thinking Sphinx - Resque Deltas}
  s.description = %q{Manage delta indexes via Resque for Thinking Sphinx}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'thinking-sphinx', '>= 3.0.0'
  s.add_dependency "resque", "~> 1.10"
  s.add_dependency "resque-lock-timeout", "~> 0.4"

  s.add_development_dependency 'activerecord',     '>= 3.1.0'
  s.add_development_dependency 'database_cleaner', '>= 0.5.2'
  s.add_development_dependency 'mysql2',           '>= 0.3.12b4'
  s.add_development_dependency 'rake',             '>= 0.8.7'
  s.add_development_dependency 'rspec',            '>= 2.11.0'
end
