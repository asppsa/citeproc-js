# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'citeproc/js/version'

Gem::Specification.new do |s|
  s.name        = 'citeproc-js'
  s.version     = CiteProc::JS::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Sylvester Keil', 'Alastair PHaro']
  s.email       = ['http://sylvester.keil.or.at']
  s.homepage    = 'http://inukshuk.github.com/citeproc-js'
  s.summary     = 'A citeproc engine based on citeproc-js.'
  s.description = 'A citeproc engine based on the citeproc-js CSL (Citation Style Language) processor.'
  s.license     = 'AGPLv3'

  s.add_runtime_dependency('citeproc', ['~>0.0.5'])
  s.add_runtime_dependency('nokogiri', ['~> 1.5.5'])

  s.add_development_dependency('rspec', ['>=2.6.0'])
  s.add_development_dependency('watchr', ['>=0.7'])

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = []
  s.require_path = 'lib'

  s.rdoc_options      = %w{--line-numbers --inline-source --title "CiteProc-JS" --main README.md --webcvs=http://github.com/inukshuk/citeproc-js/tree/master/}
  s.extra_rdoc_files  = %w{README.md}
  
end

# vim: syntax=ruby
